import FoundationModels

/// The structured output the on-device LLM produces for each school message screenshot.
/// @Generable tells Foundation Models exactly which fields to populate,
/// and @Guide gives natural-language instructions for each field.
@Generable
struct SchoolMessageAnalysis: Sendable, Equatable {

    @Guide(description: "A 2–3 sentence summary of what the school message is about and what kind of response the sender likely expects from the parent.")
    var situationSummary: String

    @Guide(description: "A warm, thankful reply that acknowledges the message positively and shows appreciation for the teacher's effort (1–3 sentences).")
    var gratefulReply: String

    @Guide(description: "A reply expressing genuine concern about the child's progress, behaviour, or the situation described, while remaining respectful (1–3 sentences).")
    var concernedReply: String

    @Guide(description: "A reply volunteering to help, attend, or support the school's request enthusiastically (1–3 sentences).")
    var supportiveReply: String

    @Guide(description: "A polite, tactful reply that navigates a disagreement or sensitive topic without confrontation, while still making the parent's perspective clear (1–3 sentences).")
    var diplomaticReply: String

    @Guide(description: "A clear, boundary-setting reply that politely declines a request or pushes back on something unreasonable, while keeping the relationship professional (1–3 sentences).")
    var firmReply: String

    @Guide(description: "A reply requesting more details, clarification, or a follow-up meeting to better understand the situation (1–3 sentences).")
    var clarifyingReply: String

    /// The tone the model considers the best fit for this specific message.
    /// Optional so that the UI degrades gracefully if the model omits it.
    @Guide(description: "The single tone name that best fits this school message. Must be exactly one of the following strings: 'Grateful', 'Concerned', 'Supportive', 'Diplomatic', 'Firm', 'Clarifying'.")
    var recommendedToneName: String? = nil

    /// Parsed from `recommendedToneName`; nil if the model returned an unrecognised value.
    ///
    /// Case-insensitive so that model variance ("grateful" vs "Grateful") degrades
    /// gracefully to the correct tone rather than silently returning nil.
    var recommendedTone: ReplyTone? {
        guard let name = recommendedToneName else { return nil }
        return ReplyTone.allCases.first { $0.rawValue.lowercased() == name.lowercased() }
    }

    func reply(for tone: ReplyTone) -> String {
        switch tone {
        case .grateful:   gratefulReply
        case .concerned:  concernedReply
        case .supportive: supportiveReply
        case .diplomatic: diplomaticReply
        case .firm:       firmReply
        case .clarifying: clarifyingReply
        }
    }
}
