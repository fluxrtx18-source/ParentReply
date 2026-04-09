import Foundation

// MARK: - Step

enum OnboardingStep: Int, CaseIterable {
    case welcome       = 0
    case carousel      = 1
    case painPoints    = 2
    case solution      = 3
    case demo          = 4
    case valueDelivery = 5
    case paywall       = 6
}

// MARK: - Pain Points

enum OnboardingPainPoints {
    static let headline = "What makes school replies stressful?"
    static let options: [String] = [
        "I overthink every word to the teacher",
        "I'm not sure what tone is appropriate",
        "English isn't my first language",
        "I don't want to seem like a difficult parent",
        "I never know if I should push back or agree",
        "I just don't have time to craft replies",
        "I worry my message sounds too cold or too emotional"
    ]
}

// MARK: - Personalised Solution

struct SolutionItem: Identifiable {
    let id = UUID()
    let icon: String
    let painPoint: String
    let solution: String
}

enum PersonalisedSolutionData {
    static let items: [SolutionItem] = [
        SolutionItem(
            icon: "text.bubble.fill",
            painPoint: "Overthinking every word",
            solution: "Six ready-made replies in seconds — just pick the tone that fits"
        ),
        SolutionItem(
            icon: "sparkles",
            painPoint: "Not sure what tone works",
            solution: "AI suggests the best tone for each message — no guesswork"
        ),
        SolutionItem(
            icon: "lock.shield.fill",
            painPoint: "Privacy concerns",
            solution: "100% on-device — your messages never leave your phone"
        ),
        SolutionItem(
            icon: "gift.fill",
            painPoint: "Paying before you try",
            solution: "Your first 5 replies are completely free — no credit card"
        )
    ]
}

// MARK: - Feature cards (carousel step)

struct FeatureCard: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let headline: String
    let body: String
    let accentHex: String
}

extension FeatureCard {
    static let all: [FeatureCard] = [
        FeatureCard(
            icon: "camera.viewfinder",
            label: "Screenshot It",
            headline: "Snap. Paste. Done.",
            body: "Take a screenshot of any school message — email, ClassDojo, Remind, or text.",
            accentHex: "#0D9488"
        ),
        FeatureCard(
            icon: "sparkles",
            label: "AI Reads It",
            headline: "On-device AI, zero cloud.",
            body: "Apple Intelligence reads the message and crafts six parent-appropriate replies privately.",
            accentHex: "#10B3D1"
        ),
        FeatureCard(
            icon: "hand.tap.fill",
            label: "Tap to Copy",
            headline: "Pick your tone. Reply.",
            body: "Choose Grateful, Concerned, Supportive, Diplomatic, Firm, or Clarifying — one tap to copy.",
            accentHex: "#D97706"
        )
    ]
}

// MARK: - Demo message

struct DemoMessage {
    let from: String
    let subject: String
    let body: String
}

enum DemoMessages {
    static let message = DemoMessage(
        from: "Ms. Thompson",
        subject: "Behaviour Note",
        body: "Hi, I wanted to let you know that Jake had some trouble staying focused in class today. He was talking during the lesson and had to be redirected several times. I'd love to work together to help him stay on track. Would you be available for a quick chat this week?"
    )

    static let demoReplies: [(tone: ReplyTone, text: String)] = [
        (.grateful, "Thank you for letting me know, Ms. Thompson. We appreciate you taking the time to reach out and we'll talk to Jake about staying focused."),
        (.concerned, "Thanks for flagging this. Has this been happening often? We want to make sure there isn't something else going on."),
        (.diplomatic, "I appreciate you sharing this. Jake is usually quite focused at home — could there be something in the classroom environment contributing?")
    ]
}

// MARK: - UserDefaults keys

enum UserDefaultsKeys {
    static let onboardingComplete = "onboardingComplete"
}
