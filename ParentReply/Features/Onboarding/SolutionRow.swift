import SwiftUI

struct SolutionRow: View {
    let item: SolutionItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppDesign.Color.accent.opacity(0.10))
                    .frame(width: 48, height: 48)
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppDesign.Color.accent)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.painPoint)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(AppDesign.Color.textSecondary)
                    .strikethrough(true, color: AppDesign.Color.textSecondary.opacity(0.6))

                Text(item.solution)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppDesign.Color.surface)
                .shadow(color: .black.opacity(0.12), radius: 8, y: 2)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppDesign.Color.border, lineWidth: 1)
        }
    }
}
