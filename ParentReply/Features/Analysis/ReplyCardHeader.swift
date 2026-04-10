import SwiftUI

/// Tone badge, optional "Suggested" pill, and copy-state indicator for a reply card.
struct ReplyCardHeader: View {
    let tone: ReplyTone
    let isCopied: Bool
    let isRecommended: Bool

    var body: some View {
        HStack {
            // Tone badge
            HStack(spacing: AppDesign.Spacing.xs) {
                Image(systemName: tone.icon)
                Text(tone.displayName.uppercased())
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .tracking(0.5)
            }
            .padding(.horizontal, AppDesign.Spacing.sm)
            .padding(.vertical, 6)
            .background(tone.color.opacity(isCopied ? 0.25 : 0.15))
            .foregroundStyle(tone.color)
            .clipShape(.capsule)
            .overlay {
                Capsule().strokeBorder(tone.color.opacity(isCopied ? 0.6 : 0.3), lineWidth: 1)
            }

            // Recommended pill
            if isRecommended {
                HStack(spacing: 3) {
                    Image(systemName: "sparkles")
                        .accessibilityHidden(true)
                    Text("Suggested")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                }
                .foregroundStyle(AppDesign.Color.accent)
                .padding(.horizontal, AppDesign.Spacing.sm)
                .padding(.vertical, 4)
                .background(AppDesign.Color.accent.opacity(0.12))
                .clipShape(.capsule)
                .overlay {
                    Capsule().strokeBorder(AppDesign.Color.accent.opacity(0.3), lineWidth: 1)
                }
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            // Copy state indicator
            HStack(spacing: AppDesign.Spacing.xs) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                Text(isCopied ? "Copied" : "Copy")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(isCopied ? tone.color : AppDesign.Color.textSecondary)
            .padding(.horizontal, AppDesign.Spacing.sm)
            .padding(.vertical, 6)
            .background(isCopied ? tone.color.opacity(0.12) : Color.white.opacity(0.04))
            .clipShape(.capsule)
        }
    }
}
