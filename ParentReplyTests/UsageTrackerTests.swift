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

    @Test("Count persists across tracker instances on the same UserDefaults")
    @MainActor
    func persistsAcrossInstances() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let tracker1 = UsageTracker(defaults: defaults)
        tracker1.recordAnalysis()
        tracker1.recordAnalysis()

        let tracker2 = UsageTracker(defaults: defaults)
        #expect(tracker2.analysisCount == 2)
    }

    @Test("Resets count to zero when a new calendar week begins")
    @MainActor
    func resetsOnNewWeek() {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        // Simulate state persisted from 8 days ago (previous week)
        defaults.set(5, forKey: "weeklyAnalysisCount")
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date.now)!
        defaults.set(eightDaysAgo, forKey: "weekStartDate")

        // init() calls refresh() → resetIfNewWeek(); should detect new week and reset
        let tracker = UsageTracker(defaults: defaults)
        #expect(tracker.analysisCount == 0)
        #expect(!tracker.hasReachedLimit)
        #expect(tracker.remaining == UsageTracker.weeklyFreeLimit)
    }

    @Test("Preserves count when app is re-launched within the same week")
    @MainActor
    func preservesCountSameWeek() {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        // Simulate 3 analyses recorded today (same week)
        defaults.set(3, forKey: "weeklyAnalysisCount")
        defaults.set(Date.now, forKey: "weekStartDate")

        let tracker = UsageTracker(defaults: defaults)
        #expect(tracker.analysisCount == 3)
        #expect(tracker.remaining == UsageTracker.weeklyFreeLimit - 3)
    }

    // MARK: - Edge cases

    @Test("remaining never goes negative when analyses exceed the weekly limit")
    @MainActor
    func remainingNeverNegative() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let tracker = UsageTracker(defaults: defaults)
        let overLimit = UsageTracker.weeklyFreeLimit + 3
        for _ in 0..<overLimit { tracker.recordAnalysis() }
        #expect(tracker.remaining == 0,
                "remaining must clamp at 0, not go negative; got \(tracker.remaining)")
        #expect(tracker.hasReachedLimit)
    }

    @Test("refresh() re-reads count written externally to UserDefaults")
    @MainActor
    func refreshReadsExternalWrite() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let tracker = UsageTracker(defaults: defaults)
        #expect(tracker.analysisCount == 0)

        // Simulate an external write (e.g., from an app extension) then call refresh()
        defaults.set(4, forKey: "weeklyAnalysisCount")
        defaults.set(Date.now, forKey: "weekStartDate")

        tracker.refresh()
        #expect(tracker.analysisCount == 4,
                "refresh() must pick up the externally written count")
        #expect(tracker.remaining == UsageTracker.weeklyFreeLimit - 4)
    }
}
