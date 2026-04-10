import SwiftUI

/// Shown at the top of HomeView when the user's subscription is in billing retry.
/// Guides them to update their payment method in App Store settings.
struct BillingIssueBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Payment issue")
                    .font(AppDesign.Font.subhead)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppDesign.Color.textPrimary)
                Text("Update your payment method in Settings > Apple ID > Subscriptions to keep your access.")
                    .font(AppDesign.Font.caption)
                    .foregroundStyle(AppDesign.Color.textSecondary)
            }
        }
        .padding(AppDesign.Spacing.md)
        .background(Color.orange.opacity(0.08))
        .clipShape(.rect(cornerRadius: AppDesign.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.Radius.md)
                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
        }
    }
}

#Preview {
    BillingIssueBanner()
        .padding()
        .background(AppDesign.Color.background)
        .preferredColorScheme(.dark)
}
