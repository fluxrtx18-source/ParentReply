import SwiftUI

/// Single reply preview row shown in the value delivery revealed view.
struct ReplyPreviewRow: View {
    let tone: ReplyTone
    let text: String
    let index: Int

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(tone.color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: tone.icon)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(tone.color)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(tone.displayName.uppercased())
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .tracking(0.8)
                    .foregroundStyle(tone.color)
                Text(text)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "doc.on.doc")
                .font(.system(size: 12))
                .foregroundStyle(AppDesign.Color.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppDesign.Color.surface)
                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppDesign.Color.border, lineWidth: 1)
        }
    }
}
