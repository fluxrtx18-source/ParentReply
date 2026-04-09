import SwiftUI

enum ReplyTone: String, CaseIterable, Identifiable {
    case grateful   = "Grateful"
    case concerned  = "Concerned"
    case supportive = "Supportive"
    case diplomatic = "Diplomatic"
    case firm       = "Firm"
    case clarifying = "Clarifying"

    var id: String { rawValue }

    /// User-facing label. Intentionally separated from rawValue so the
    /// internal identifier stays stable while display copy can evolve freely.
    var displayName: String {
        switch self {
        case .grateful:   String(localized: "Grateful")
        case .concerned:  String(localized: "Concerned")
        case .supportive: String(localized: "Supportive")
        case .diplomatic: String(localized: "Diplomatic")
        case .firm:       String(localized: "Firm")
        case .clarifying: String(localized: "Clarifying")
        }
    }

    var color: Color {
        switch self {
        case .grateful:   Color(red: 0.05, green: 0.58, blue: 0.53)  // teal
        case .concerned:  Color(red: 0.91, green: 0.49, blue: 0.15)  // amber
        case .supportive: Color(red: 0.29, green: 0.56, blue: 0.89)  // sky blue
        case .diplomatic: Color(red: 0.61, green: 0.35, blue: 0.71)  // purple
        case .firm:       Color(red: 0.90, green: 0.30, blue: 0.24)  // red
        case .clarifying: Color(red: 0.40, green: 0.65, blue: 0.28)  // green
        }
    }

    var icon: String {
        switch self {
        case .grateful:   "heart.text.square"
        case .concerned:  "exclamationmark.bubble"
        case .supportive: "hand.raised.fill"
        case .diplomatic: "scale.3d"
        case .firm:       "shield.fill"
        case .clarifying: "questionmark.circle"
        }
    }
}
