import Testing
@testable import ParentReply

/// Guards rawValue stability for `ReplyTone`.
///
/// `SchoolMessageAnalysis.recommendedTone` matches against `rawValue` strings. If a case
/// is accidentally renamed, the feature silently returns `nil` for every message —
/// users lose the recommended tone highlight with no error in the logs.
@Suite("ReplyTone — rawValue stability and properties")
struct ReplyToneTests {

    // MARK: - rawValue stability (regression tripwires)

    @Test("rawValues match the expected stable strings", arguments: [
        (ReplyTone.grateful,   "Grateful"),
        (ReplyTone.concerned,  "Concerned"),
        (ReplyTone.supportive, "Supportive"),
        (ReplyTone.diplomatic, "Diplomatic"),
        (ReplyTone.firm,       "Firm"),
        (ReplyTone.clarifying, "Clarifying"),
    ] as [(ReplyTone, String)])
    func rawValueIsStable(tone: ReplyTone, expected: String) {
        #expect(tone.rawValue == expected,
                "\(tone) rawValue changed — this breaks recommendedTone parsing for all existing users")
    }

    // MARK: - Identity

    @Test("id equals rawValue for all tones", arguments: ReplyTone.allCases)
    func idEqualsRawValue(tone: ReplyTone) {
        #expect(tone.id == tone.rawValue)
    }

    // MARK: - Completeness

    @Test("allCases contains exactly 6 tones")
    func allCasesCount() {
        #expect(ReplyTone.allCases.count == 6)
    }

    @Test("displayName is non-empty for all tones", arguments: ReplyTone.allCases)
    func displayNameNonEmpty(tone: ReplyTone) {
        #expect(!tone.displayName.isEmpty,
                "\(tone).displayName must not be empty")
    }

    @Test("icon is a non-empty SF Symbol name for all tones", arguments: ReplyTone.allCases)
    func iconNonEmpty(tone: ReplyTone) {
        #expect(!tone.icon.isEmpty,
                "\(tone).icon must not be empty")
    }
}
