import SwiftUI

struct PaywallFreeTrialBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "gift.fill")
                .font(.system(.footnote, design: .rounded, weight: .semibold))
                .foregroundStyle(AppDesign.Color.accent)
                .accessibilityHidden(true)
            Text("Start your free trial — no charge until it ends")
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(AppDesign.Color.accent)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppDesign.Color.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
