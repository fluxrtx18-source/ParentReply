import Testing
import UIKit
import Foundation
@testable import ParentReply

// MARK: - Mock services

private struct MockTextExtractor: TextExtracting, @unchecked Sendable {
    let result: Result<String, any Error>
    init(returning text: String) { result = .success(text) }
    init(throwing error: any Error) { result = .failure(error) }
    func extractText(from image: UIImage) async throws -> String { try result.get() }
}

private struct MockMessageAnalyzer: MessageAnalyzing, @unchecked Sendable {
    let result: Result<SchoolMessageAnalysis, any Error>
    init(returning analysis: SchoolMessageAnalysis) { result = .success(analysis) }
    init(throwing error: any Error) { result = .failure(error) }
    func analyze(messageText: String) async throws -> SchoolMessageAnalysis { try result.get() }
}

// MARK: - Helpers

private extension SchoolMessageAnalysis {
    static let fixture = SchoolMessageAnalysis(
        situationSummary: "The teacher wants to discuss progress.",
        gratefulReply:    "Thank you for reaching out.",
        concernedReply:   "We are concerned and would like to talk.",
        supportiveReply:  "We would be happy to help.",
        diplomaticReply:  "We understand and will do our best.",
        firmReply:        "We must respectfully decline.",
        clarifyingReply:  "Could you please clarify the details?",
        recommendedToneName: "Grateful"
    )
}

private extension UIImage {
    /// Minimal 1×1 white image suitable for injecting into mocked analysis flows.
    static let stub: UIImage = {
        UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
            .image { ctx in
                UIColor.white.setFill()
                ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            }
    }()
}

private extension UsageTracker {
    static func isolated() -> UsageTracker {
        UsageTracker(defaults: UserDefaults(suiteName: "test.\(UUID().uuidString)")!)
    }
}

// MARK: - Suite

@Suite("AnalysisViewModel")
@MainActor
struct AnalysisViewModelTests {

    // MARK: Happy path

    @Test("Transitions to complete after successful analysis")
    func happyPath() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello teacher"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        await vm.analyze(image: .stub, usageTracker: .isolated())
        #expect(vm.state == .complete)
        #expect(vm.analysis != nil)
    }

    // MARK: Error paths

    @Test("Enters failed state when Vision cannot read image")
    func visionFailure() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(throwing: VisionService.VisionError.noTextFound),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        await vm.analyze(image: .stub, usageTracker: .isolated())
        guard case .failed(let msg) = vm.state else {
            Issue.record("Expected .failed, got \(vm.state)")
            return
        }
        #expect(!msg.isEmpty)
    }

    @Test("Enters failed state when AI service throws a localized error")
    func aiFailureWithLocalizedError() async {
        struct SentinelError: LocalizedError {
            var errorDescription: String? { "Sentinel AI failure" }
        }
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(throwing: SentinelError())
        )
        await vm.analyze(image: .stub, usageTracker: .isolated())
        guard case .failed(let msg) = vm.state else {
            Issue.record("Expected .failed state")
            return
        }
        #expect(msg == "Sentinel AI failure")
    }

    // MARK: Usage tracking

    @Test("Free user usage count increments on successful analysis")
    func freeUserIncrementsCount() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        let tracker = UsageTracker.isolated()
        await vm.analyze(image: .stub, usageTracker: tracker, isSubscribed: false)
        #expect(tracker.analysisCount == 1)
    }

    @Test("Subscribed user does not increment usage count")
    func subscribedSkipsUsageCount() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        let tracker = UsageTracker.isolated()
        await vm.analyze(image: .stub, usageTracker: tracker, isSubscribed: true)
        #expect(tracker.analysisCount == 0)
    }

    @Test("Usage count does not increment when Vision throws")
    func countNotIncrementedOnVisionError() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(throwing: VisionService.VisionError.invalidImage),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        let tracker = UsageTracker.isolated()
        await vm.analyze(image: .stub, usageTracker: tracker, isSubscribed: false)
        #expect(tracker.analysisCount == 0)
    }

    @Test("Usage count does not increment when AI service throws")
    func countNotIncrementedOnAIError() async {
        struct SentinelAIError: LocalizedError {
            var errorDescription: String? { "AI unavailable" }
        }
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(throwing: SentinelAIError())
        )
        let tracker = UsageTracker.isolated()
        await vm.analyze(image: .stub, usageTracker: tracker, isSubscribed: false)
        #expect(tracker.analysisCount == 0,
                "A failed AI call must not consume a free use")
        guard case .failed = vm.state else {
            Issue.record("Expected .failed state after AI error; got \(vm.state)")
            return
        }
    }

    // MARK: Usage limit enforcement

    @Test("Rejects analysis with helpful message when free user has reached weekly limit")
    func limitEnforced() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        let tracker = UsageTracker.isolated()
        for _ in 0..<UsageTracker.weeklyFreeLimit { tracker.recordAnalysis() }

        await vm.analyze(image: .stub, usageTracker: tracker, isSubscribed: false)
        guard case .failed(let msg) = vm.state else {
            Issue.record("Expected .failed when limit reached")
            return
        }
        #expect(msg.contains("free replies"))
    }

    @Test("Subscribed user bypasses weekly limit")
    func subscribedBypassesLimit() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        let tracker = UsageTracker.isolated()
        for _ in 0..<UsageTracker.weeklyFreeLimit { tracker.recordAnalysis() }

        await vm.analyze(image: .stub, usageTracker: tracker, isSubscribed: true)
        #expect(vm.state == .complete)
    }

    // MARK: Re-entry guard

    @Test("Second analyze call is ignored when state is already complete")
    func reEntryGuardComplete() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        let tracker = UsageTracker.isolated()
        await vm.analyze(image: .stub, usageTracker: tracker, isSubscribed: false)
        #expect(vm.state == .complete)
        #expect(tracker.analysisCount == 1)

        // Should be ignored — state is .complete, not .idle or .failed
        await vm.analyze(image: .stub, usageTracker: tracker, isSubscribed: false)
        #expect(tracker.analysisCount == 1)
    }

    // MARK: Retry

    @Test("Analysis succeeds after reset from failed state")
    func retryAfterFailure() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        let tracker = UsageTracker.isolated()
        vm.fail(with: "Simulated prior failure")
        #expect(vm.state.isFailed)

        await vm.analyze(image: .stub, usageTracker: tracker, isSubscribed: false)
        #expect(vm.state == .complete)
    }

    // MARK: Reset

    @Test("Reset clears state and analysis")
    func resetClearsState() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        await vm.analyze(image: .stub, usageTracker: .isolated())
        #expect(vm.state == .complete)

        vm.reset()
        #expect(vm.state == .idle)
        #expect(vm.analysis == nil)
        #expect(vm.copiedTone == nil)
    }

    // MARK: Copy

    @Test("copyReply sets copiedTone to the requested tone")
    func copyReplySetscopiedTone() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        await vm.analyze(image: .stub, usageTracker: .isolated())
        #expect(vm.analysis != nil)
        vm.copyReply(for: .grateful)
        #expect(vm.copiedTone == .grateful)
    }

    @Test("Copying a different tone updates copiedTone")
    func copyReplySwitchesTone() async {
        let vm = AnalysisViewModel(
            visionService: MockTextExtractor(returning: "Hello"),
            aiService: MockMessageAnalyzer(returning: .fixture)
        )
        await vm.analyze(image: .stub, usageTracker: .isolated())
        vm.copyReply(for: .grateful)
        vm.copyReply(for: .firm)
        #expect(vm.copiedTone == .firm)
    }
}
