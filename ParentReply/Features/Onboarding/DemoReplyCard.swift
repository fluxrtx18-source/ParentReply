import SwiftUI

/// Expandable reply card used in the interactive demo step.
struct DemoReplyCard: View {
    let tone: ReplyTone
    let text: String
    let isExpanded: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: tone.icon)
                        .font(.system(size: 12))
                    Text(tone.displayName.uppercased())
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundStyle(tone.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(tone.color.opacity(0.12), in: Capsule())

                Text(text)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textPrimary.opacity(0.9))
                    .lineSpacing(3)
                    .lineLimit(isExpanded ? nil : 2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppDesign.Color.surface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isExpanded ? tone.color : AppDesign.Color.border,
                        lineWidth: isExpanded ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tone.displayName) reply: \(text)")
        .accessibilityHint(isExpanded ? "Double-tap to collapse" : "Double-tap to expand")
    }
}
