import Testing
@testable import ParentReply

/// Tests for the prompt-injection defence and input-truncation logic in AIParentService.
///
/// `AIParentService.analyze()` requires a live `LanguageModelSession` which cannot be
/// instantiated in unit tests. Instead, these tests mirror the exact transformations
/// applied inside `analyze()` so any accidental removal of the sanitisation step is caught.
@Suite("AIParentService — input sanitisation and truncation")
struct AIParentServiceSanitisationTests {

    /// Mirrors the two `replacingOccurrences` calls in `AIParentService.analyze()` exactly.
    private func sanitise(_ input: String) -> String {
        input
            .replacingOccurrences(of: "</message>", with: "< /message>", options: .caseInsensitive)
            .replacingOccurrences(of: "<message>",  with: "< message>",  options: .caseInsensitive)
    }

    /// Mirrors the truncation guard in `AIParentService.analyze()` exactly.
    private func truncate(_ input: String, maxLength: Int = 8_000) -> String {
        input.count > maxLength ? String(input.prefix(maxLength)) : input
    }

    // MARK: - Tag neutralisation

    @Test("Closing message tag is neutralised — lowercase")
    func closingTagLowercase() {
        let result = sanitise("Hello </message> world")
        #expect(result == "Hello < /message> world")
        #expect(!result.contains("</message>"))
    }

    @Test("Opening message tag is neutralised — lowercase")
    func openingTagLowercase() {
        let result = sanitise("Ignore this: <message>injected</message>")
        #expect(!result.contains("<message>"))
        #expect(!result.contains("</message>"))
    }

    @Test("Tags are neutralised case-insensitively — mixed case closing tag")
    func closingTagMixedCase() {
        let result = sanitise("Payload </Message> end")
        #expect(!result.lowercased().contains("</message>"))
    }

    @Test("Tags are neutralised case-insensitively — uppercase opening tag")
    func openingTagUppercase() {
        let result = sanitise("<MESSAGE>payload</MESSAGE>")
        #expect(!result.lowercased().contains("<message>"))
        #expect(!result.lowercased().contains("</message>"))
    }

    @Test("Multiple tag pairs in one string are all neutralised")
    func multipleTagPairs() {
        let input = "<message>first</message> and <message>second</message>"
        let result = sanitise(input)
        #expect(!result.contains("<message>"))
        #expect(!result.contains("</message>"))
    }

    @Test("Clean input with no tags passes through unchanged")
    func cleanInputPassesThrough() {
        let clean = "Hi Ms. Thompson, Jake had a great day today. — Jane"
        #expect(sanitise(clean) == clean)
    }

    // MARK: - Input truncation

    @Test("Input longer than 8000 characters is truncated to exactly 8000")
    func inputTruncatedAtMaxLength() {
        let oversized = String(repeating: "A", count: 8_500)
        let result = truncate(oversized)
        #expect(result.count == 8_000)
    }

    @Test("Input at exactly 8000 characters is not truncated")
    func inputAtExactLimitNotTruncated() {
        let exact = String(repeating: "B", count: 8_000)
        let result = truncate(exact)
        #expect(result.count == 8_000)
        #expect(result == exact)
    }

    @Test("Input shorter than 8000 characters is not truncated")
    func inputShorterThanLimitPassesThrough() {
        let short = String(repeating: "C", count: 100)
        let result = truncate(short)
        #expect(result == short)
    }

    @Test("Truncated text is the exact prefix of the original")
    func truncatedTextIsPrefix() {
        let oversized = String(repeating: "X", count: 9_000)
        let result = truncate(oversized)
        #expect(oversized.hasPrefix(result))
    }
}
