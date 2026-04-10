import SwiftUI

struct PaywallTimelineSection: View {
    let timeline: [(icon: String, title: String, body: String)]

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [AppDesign.Color.accent, AppDesign.Color.accent.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 54)

                VStack(spacing: 0) {
                    Spacer().frame(height: 16)
                    iconBadge(timeline[0].icon, opacity: 1.0)
                    Spacer()
                    iconBadge(timeline[1].icon, opacity: 0.80)
                    Spacer()
                    iconBadge(timeline[2].icon, opacity: 0.45)
                    Spacer().frame(height: 28)
                }
                .frame(width: 54)
            }
            .frame(width: 54, height: 260)

            VStack(alignment: .leading, spacing: 0) {
                timelineRow(title: timeline[0].title, body: timeline[0].body)
                Spacer()
                timelineRow(title: timeline[1].title, body: timeline[1].body)
                Spacer()
                timelineRow(title: timeline[2].title, body: timeline[2].body)
            }
            .frame(height: 260)
            .padding(.trailing, 6)
        }
        .padding(.horizontal, 20)
    }

    private func iconBadge(_ symbol: String, opacity: Double) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.22 * opacity))
                .frame(width: 40, height: 40)
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white.opacity(opacity))
        }
    }

    private func timelineRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(.callout, design: .rounded, weight: .bold))
                .foregroundStyle(AppDesign.Color.textPrimary)
            Text(body)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppDesign.Color.textSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
