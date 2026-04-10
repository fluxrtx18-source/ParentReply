import SwiftUI

@MainActor
@Observable
final class AnalysisViewModel {

    // MARK: - State machine
    enum State: Equatable {
        case idle
        case extractingText
        case analyzing
        case complete
        case failed(String)

        var isFailed: Bool {
            if case .failed = self { return true }
            return false
        }
    }

    // MARK: - Observed properties
    private(set) var state: State = .idle
    private(set) var analysis: SchoolMessageAnalysis?
    private(set) var copiedTone: ReplyTone?

    // MARK: - Services
    private let visionService:  any TextExtracting
    private let aiService:      any MessageAnalyzing

    init(
        visionService: some TextExtracting   = VisionService(),
        aiService:     some MessageAnalyzing  = AIParentService()
    ) {
        self.visionService = visionService
        self.aiService     = aiService
    }

    // MARK: - Analysis

    func analyze(image: UIImage, usageTracker: UsageTracker, isSubscribed: Bool = false) async {
        guard state == .idle || state.isFailed else { return }

        if !isSubscribed && usageTracker.hasReachedLimit {
            state = .failed("You've used all \(UsageTracker.weeklyFreeLimit) free replies this week. Upgrade to continue.")
            return
        }

        state = .extractingText

        do {
            let text    = try await visionService.extractText(from: image)
            state       = .analyzing
            let result  = try await aiService.analyze(messageText: text)
            analysis    = result
            if !isSubscribed { usageTracker.recordAnalysis() }
            state       = .complete
        } catch {
            let message: String
            if let localized = error as? LocalizedError,
               let desc = localized.errorDescription {
                message = desc
            } else {
                #if DEBUG
                message = error.localizedDescription
                #else
                message = String(localized: "Analysis failed. Please try again.")
                #endif
            }
            state = .failed(message)
        }
    }

    // MARK: - Private
    @ObservationIgnored
    private var copyFeedbackTask: Task<Void, Never>?

    deinit {
        copyFeedbackTask?.cancel()
    }

    // MARK: - Copy

    func copyReply(for tone: ReplyTone) {
        guard let text = analysis?.reply(for: tone) else { return }
        UIPasteboard.general.setItems(
            [["public.utf8-plain-text": text]],
            options: [.expirationDate: Date.now.addingTimeInterval(120)]
        )
        copiedTone = tone

        copyFeedbackTask?.cancel()
        copyFeedbackTask = Task {
            try? await Task.sleep(for: .seconds(2))
            if copiedTone == tone {
                copiedTone = nil
            }
        }
    }

    /// Transitions to the failed state from outside the view model.
    func fail(with message: String) {
        state = .failed(message)
    }

    // MARK: - Reset

    func reset() {
        copyFeedbackTask?.cancel()
        copyFeedbackTask = nil
        state      = .idle
        analysis   = nil
        copiedTone = nil
    }
}
