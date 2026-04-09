import SwiftUI

/// A single tone-specific reply card. Tap anywhere to copy the reply text.
struct ReplyCardView: View {
    let tone: ReplyTone
    let replyText: String
    let isCopied: Bool
    var isRecommended: Bool = false
    var isLocked: Bool = false
    let onCopy: () -> Void

    /// Fixed placeholder text shown behind the blur for locked tones.
    /// Prevents real reply content from leaking into the render buffer or accessibility tree.
    private static let redactedPlaceholder = "This reply is available with ParentReply Pro. Upgrade to unlock all six tone options and the situation summary."

    var body: some View {
        Button(action: onCopy) {
            cardContent
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLocked
            ? "\(tone.displayName) reply — locked"
            : "\(tone.displayName) reply: \(replyText)")
        .accessibilityHint(isLocked
            ? Text("Double-tap to upgrade")
            : isCopied ? Text("Copied to clipboard") : Text("Double-tap to copy"))
        .sensoryFeedback(.success, trigger: isCopied)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            headerRow

            if isLocked {
                ZStack {
                    Text(Self.redactedPlaceholder)
                        .font(AppDesign.Font.body)
                        .foregroundStyle(AppDesign.Color.textPrimary.opacity(0.95))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .blur(radius: 5)
                        .drawingGroup()
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)

                    HStack(spacing: AppDesign.Spacing.xs) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                        Text("Upgrade to unlock")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(AppDesign.Color.accent)
                    .padding(.horizontal, AppDesign.Spacing.md)
                    .padding(.vertical, AppDesign.Spacing.sm)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(replyText)
                    .font(AppDesign.Font.body)
                    .foregroundStyle(AppDesign.Color.textPrimary.opacity(0.95))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDesign.Spacing.md)
        .background(
            ZStack {
                AppDesign.Color.surface
                LinearGradient(
                    colors: [tone.color.opacity(isCopied ? 0.35 : 0.08), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.Radius.lg, style: .continuous)
                .strokeBorder(
                    isCopied ? tone.color : AppDesign.Color.border.opacity(0.5),
                    lineWidth: isCopied ? 2 : 1
                )
        }
        .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
        .animation(AppDesign.Anim.snappy, value: isCopied)
    }

    private var headerRow: some View {
        HStack {
            HStack(spacing: AppDesign.Spacing.xs) {
                Image(systemName: tone.icon)
                Text(tone.displayName.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(0.5)
            }
            .padding(.horizontal, AppDesign.Spacing.sm)
            .padding(.vertical, 6)
            .background(tone.color.opacity(isCopied ? 0.25 : 0.15))
            .foregroundStyle(tone.color)
            .clipShape(.capsule)
            .overlay(
                Capsule().strokeBorder(tone.color.opacity(isCopied ? 0.6 : 0.3), lineWidth: 1)
            )

            if isRecommended {
                HStack(spacing: 3) {
                    Image(systemName: "sparkles")
                    Text("Suggested")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(AppDesign.Color.accent)
                .padding(.horizontal, AppDesign.Spacing.sm)
                .padding(.vertical, 4)
                .background(AppDesign.Color.accent.opacity(0.12))
                .clipShape(.capsule)
                .overlay(Capsule().strokeBorder(AppDesign.Color.accent.opacity(0.3), lineWidth: 1))
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()

            HStack(spacing: AppDesign.Spacing.xs) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                Text(isCopied ? "Copied" : "Copy")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(isCopied ? tone.color : AppDesign.Color.textSecondary)
            .padding(.horizontal, AppDesign.Spacing.sm)
            .padding(.vertical, 6)
            .background(isCopied ? tone.color.opacity(0.12) : Color.white.opacity(0.04))
            .clipShape(.capsule)
        }
    }
}
