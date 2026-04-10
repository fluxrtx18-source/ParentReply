import SwiftUI

/// Simulated school message card shown in the interactive demo step.
struct DemoMessageCard: View {
    let demo: DemoMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(AppDesign.Color.accent.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text(String(demo.from.prefix(1)))
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(AppDesign.Color.accent)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(demo.from)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppDesign.Color.textPrimary)
                    Text(demo.subject)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppDesign.Color.textSecondary)
                }
            }

            Text(demo.body)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppDesign.Color.textPrimary.opacity(0.85))
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppDesign.Color.surface)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppDesign.Color.border, lineWidth: 1)
        }
    }
}
