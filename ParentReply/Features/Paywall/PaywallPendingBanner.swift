import SwiftUI

struct PaywallPendingBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppDesign.Color.accent)
                .accessibilityHidden(true)
            Text("Your purchase is awaiting approval. Access will unlock automatically once confirmed.")
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(AppDesign.Color.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppDesign.Color.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}
