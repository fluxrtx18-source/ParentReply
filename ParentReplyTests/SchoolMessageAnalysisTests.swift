import Testing
@testable import ParentReply

@Suite("SchoolMessageAnalysis")
struct SchoolMessageAnalysisTests {

    // MARK: - Fixture

    private static let fixture = SchoolMessageAnalysis(
        situationSummary: "The teacher wants to schedule a meeting.",
        gratefulReply:    "Grateful reply text",
        concernedReply:   "Concerned reply text",
        supportiveReply:  "Supportive reply text",
        diplomaticReply:  "Diplomatic reply text",
        firmReply:        "Firm reply text",
        clarifyingReply:  "Clarifying reply text",
        recommendedToneName: "Grateful"
    )

    // MARK: - reply(for:)

    @Test("reply(for:) returns the correct field for each tone", arguments: zip(
        ReplyTone.allCases,
        [
            "Grateful reply text",
            "Concerned reply text",
            "Supportive reply text",
            "Diplomatic reply text",
            "Firm reply text",
            "Clarifying reply text",
        ]
    ))
    func replyForTone(tone: ReplyTone, expected: String) {
        #expect(SchoolMessageAnalysisTests.fixture.reply(for: tone) == expected)
    }

    // MARK: - recommendedTone parsing

    @Test("recommendedTone matches tone names case-insensitively", arguments: [
        ("Grateful",   ReplyTone.grateful),
        ("grateful",   ReplyTone.grateful),
        ("GRATEFUL",   ReplyTone.grateful),
        ("Concerned",  ReplyTone.concerned),
        ("Supportive", ReplyTone.supportive),
        ("Diplomatic", ReplyTone.diplomatic),
        ("Firm",       ReplyTone.firm),
        ("Clarifying", ReplyTone.clarifying),
    ])
    func recommendedToneCaseInsensitive(name: String, expected: ReplyTone) {
        let analysis = SchoolMessageAnalysis(
            situationSummary: "x", gratefulReply: "x", concernedReply: "x",
            supportiveReply: "x", diplomaticReply: "x", firmReply: "x",
            clarifyingReply: "x", recommendedToneName: name
        )
        #expect(analysis.recommendedTone == expected)
    }

    @Test("recommendedTone returns nil for an unrecognised tone name")
    func recommendedToneUnrecognised() {
        let analysis = SchoolMessageAnalysis(
            situationSummary: "x", gratefulReply: "x", concernedReply: "x",
            supportiveReply: "x", diplomaticReply: "x", firmReply: "x",
            clarifyingReply: "x", recommendedToneName: "Sarcastic"
        )
        #expect(analysis.recommendedTone == nil)
    }

    @Test("recommendedTone returns nil when recommendedToneName is nil")
    func recommendedToneNilInput() {
        let analysis = SchoolMessageAnalysis(
            situationSummary: "x", gratefulReply: "x", concernedReply: "x",
            supportiveReply: "x", diplomaticReply: "x", firmReply: "x",
            clarifyingReply: "x", recommendedToneName: nil
        )
        #expect(analysis.recommendedTone == nil)
    }

    @Test("recommendedTone returns nil for an empty string")
    func recommendedToneEmpty() {
        let analysis = SchoolMessageAnalysis(
            situationSummary: "x", gratefulReply: "x", concernedReply: "x",
            supportiveReply: "x", diplomaticReply: "x", firmReply: "x",
            clarifyingReply: "x", recommendedToneName: ""
        )
        #expect(analysis.recommendedTone == nil)
    }
}
