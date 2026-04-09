import Foundation
import Testing
@testable import ParentReply

@Suite("UsageTracker")
struct UsageTrackerTests {

    @Test("Starts at zero")
    @MainActor
    func startsAtZero() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let tracker = UsageTracker(defaults: defaults)
        #expect(tracker.analysisCount == 0)
        #expect(tracker.remaining == UsageTracker.weeklyFreeLimit)
        #expect(!tracker.hasReachedLimit)
    }

    @Test("Recording increments count")
    @MainActor
    func recordIncrementsCount() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let tracker = UsageTracker(defaults: defaults)
        tracker.recordAnalysis()
        #expect(tracker.analysisCount == 1)
        #expect(tracker.remaining == UsageTracker.weeklyFreeLimit - 1)
    }

    @Test("Limit is reached after max uses")
    @MainActor
    func limitReached() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let tracker = UsageTracker(defaults: defaults)
        for _ in 0..<UsageTracker.weeklyFreeLimit {
            tracker.recordAnalysis()
        }
        #expect(tracker.hasReachedLimit)
        #expect(tracker.remaining == 0)
    }
}
