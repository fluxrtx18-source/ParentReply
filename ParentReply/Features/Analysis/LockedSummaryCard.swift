import SwiftUI

/// Blurred teaser shown in place of the situation summary for free users.
/// Tapping anywhere on the card triggers the upgrade flow.
struct LockedSummaryCard: View {
    var onUpgrade: () -> Void

    private static let placeholder = "The school has sent you a message that requires your attention. Upgrade to ParentReply Pro to see the full situation summary and all six reply tones."

    var body: some View {
        ZStack {
            SummaryCard(summary: Self.placeholder)
                .blur(radius: 8)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            Button(action: onUpgrade) {
                VStack(spacing: AppDesign.Spacing.xs) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2)
                        .foregroundStyle(AppDesign.Color.accent)

                    Text("Situation summary")
                        .font(AppDesign.Font.headline)
                        .foregroundStyle(AppDesign.Color.textPrimary)

                    Text("Understand what the school needs from you")
                        .font(AppDesign.Font.subhead)
                        .foregroundStyle(AppDesign.Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(AppDesign.Spacing.md)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: AppDesign.Radius.md, style: .continuous))
            }
            .accessibilityLabel("Situation summary — upgrade to unlock")
            .accessibilityHint("Double-tap to open upgrade options")
        }
        .clipShape(.rect(cornerRadius: AppDesign.Radius.md, style: .continuous))
    }
}

#Preview {
    LockedSummaryCard(onUpgrade: {})
        .padding()
        .background(AppDesign.Color.background)
        .preferredColorScheme(.dark)
}
