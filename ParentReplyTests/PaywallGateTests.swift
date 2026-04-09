import Testing
@testable import ParentReply

@Suite("PaywallGate")
struct PaywallGateTests {

    // MARK: - D1: Tone locking

    @Test("Free tone is Grateful")
    func freeToneIsGrateful() {
        #expect(PaywallGate.freeTone == .grateful)
    }

    @Test("Grateful is unlocked for free users")
    func gratefulUnlockedForFree() {
        #expect(!PaywallGate.isLocked(tone: .grateful, isSubscribed: false))
    }

    @Test("All non-free tones are locked for free users")
    func nonFreeTonesLockedForFree() {
        let paidTones = ReplyTone.allCases.filter { $0 != .grateful }
        for tone in paidTones {
            #expect(PaywallGate.isLocked(tone: tone, isSubscribed: false),
                    "\(tone.rawValue) should be locked for free users")
        }
    }

    @Test("All tones are unlocked for subscribers")
    func allTonesUnlockedForSubscribers() {
        for tone in ReplyTone.allCases {
            #expect(!PaywallGate.isLocked(tone: tone, isSubscribed: true),
                    "\(tone.rawValue) should be unlocked for subscribers")
        }
    }

    // MARK: - D2: Summary locking

    @Test("Summary is locked for free users")
    func summaryLockedForFree() {
        #expect(PaywallGate.isSummaryLocked(isSubscribed: false))
    }

    @Test("Summary is unlocked for subscribers")
    func summaryUnlockedForSubscribers() {
        #expect(!PaywallGate.isSummaryLocked(isSubscribed: true))
    }
}
