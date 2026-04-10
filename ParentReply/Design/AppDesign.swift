import SwiftUI

/// Single source of truth for every visual token in ParentReply.
/// Changing a value here propagates to all views automatically.
enum AppDesign {

    enum Spacing {
        static let xs:  Double = 4
        static let sm:  Double = 8
        static let md:  Double = 16
        static let lg:  Double = 24
        static let xl:  Double = 32
        static let xxl: Double = 48
    }

    enum Radius {
        static let sm: Double = 10
        static let md: Double = 18
        static let lg: Double = 26
    }

    enum Color {
        /// True black-navy background
        static let background     = SwiftUI.Color(red: 0.055, green: 0.055, blue: 0.09)
        /// Slightly lighter surface for cards
        static let surface        = SwiftUI.Color(red: 0.10,  green: 0.10,  blue: 0.15)
        /// Subtle border / divider
        static let border         = SwiftUI.Color.white.opacity(0.08)
        static let textPrimary    = SwiftUI.Color.white
        static let textSecondary  = SwiftUI.Color.white.opacity(0.55)
        /// Green used for savings / discount badges in the paywall
        static let savings        = SwiftUI.Color(red: 0.2,  green: 0.7,  blue: 0.4)
        /// Emerald teal accent — trust, education, premium
        static let accent         = SwiftUI.Color(red: 0.05, green: 0.58, blue: 0.53)
        static let accentGradient = LinearGradient(
            colors: [
                SwiftUI.Color(red: 0.05, green: 0.58, blue: 0.53),  // #0D9488
                SwiftUI.Color(red: 0.06, green: 0.70, blue: 0.82)   // #10B3D1
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum Font {
        static let largeTitle = SwiftUI.Font.system(.largeTitle,  design: .rounded, weight: .bold)
        static let title      = SwiftUI.Font.system(.title,       design: .rounded, weight: .bold)
        static let title2     = SwiftUI.Font.system(.title2,      design: .rounded, weight: .semibold)
        static let title3     = SwiftUI.Font.system(.title3,      design: .rounded, weight: .semibold)
        static let headline   = SwiftUI.Font.system(.headline,    design: .rounded)
        static let body       = SwiftUI.Font.system(.body,        design: .rounded)
        static let subhead    = SwiftUI.Font.system(.subheadline, design: .rounded)
        static let footnote   = SwiftUI.Font.system(.footnote,    design: .rounded)
        static let caption    = SwiftUI.Font.system(.caption,     design: .rounded)
    }

    enum Anim {
        static let standard = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.80)
        static let slow     = SwiftUI.Animation.easeInOut(duration: 0.45)
        static let snappy   = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.75)
    }
}
