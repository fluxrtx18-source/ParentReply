import SwiftUI

struct FeatureCardItemView: View {
    let card: FeatureCard

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: card.accentHex).opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: card.icon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color(hex: card.accentHex))
            }

            VStack(spacing: 8) {
                Text(card.label)
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(Color(hex: card.accentHex))
                    .tracking(1.2)
                    .textCase(.uppercase)

                Text(card.headline)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text(card.body)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 8)
            }

            Spacer()
        }
        .padding(.top, 28)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppDesign.Color.surface)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(AppDesign.Color.border, lineWidth: 1)
        }
    }
}
