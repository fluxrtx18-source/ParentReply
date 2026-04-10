import SwiftUI
import StoreKit

struct PaywallAutoRenewalNotice: View {
    let selectedProduct: Product?

    var body: some View {
        Text(noticeText)
            .font(.caption)
            .foregroundStyle(AppDesign.Color.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }

    private var noticeText: String {
        var base = "Subscription auto-renews unless cancelled at least 24 hours before the end of the current period."
        if let product = selectedProduct {
            base += " \(product.displayPrice) per \(product.subscription?.subscriptionPeriod.debugDescription ?? "period")."
        }
        base += " Manage or cancel anytime in Settings > Apple ID > Subscriptions."
        return base
    }
}
