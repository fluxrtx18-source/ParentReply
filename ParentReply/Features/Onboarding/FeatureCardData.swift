import Foundation

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
