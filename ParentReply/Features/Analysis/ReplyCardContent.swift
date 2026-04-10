import SwiftUI

/// The full visual card body for a reply (background, border, shadow, text or lock overlay).
/// Intended to be wrapped in a `Button` by `ReplyCardView`.
struct ReplyCardContent: View {
    let tone: ReplyTone
    let replyText: String
    let isCopied: Bool
    let isRecommended: Bool
    let isLocked: Bool

    /// Placeholder shown behind the blur so real reply text never reaches the render buffer.
    private static let redactedPlaceholder = "This reply is available with ParentReply Pro. Upgrade to unlock all six tone options and the situation summary."

    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            ReplyCardHeader(tone: tone, isCopied: isCopied, isRecommended: isRecommended)

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
                            .font(AppDesign.Font.caption)
                        Text("Upgrade to unlock")
                            .font(AppDesign.Font.footnote)
                            .fontWeight(.semibold)
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
        .clipShape(.rect(cornerRadius: AppDesign.Radius.lg, style: .continuous))
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
}

#Preview("Unlocked") {
    ReplyCardContent(
        tone: .grateful,
        replyText: "Thank you so much for letting us know. We'll talk to our child about this and make sure they understand the importance of respectful behaviour at school.",
        isCopied: false,
        isRecommended: true,
        isLocked: false
    )
    .padding()
    .background(AppDesign.Color.background)
    .preferredColorScheme(.dark)
}

#Preview("Locked") {
    ReplyCardContent(
        tone: .firm,
        replyText: "",
        isCopied: false,
        isRecommended: false,
        isLocked: true
    )
    .padding()
    .background(AppDesign.Color.background)
    .preferredColorScheme(.dark)
}
