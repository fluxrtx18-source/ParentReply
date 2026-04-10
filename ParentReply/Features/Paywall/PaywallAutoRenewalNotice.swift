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
        guard let product = selectedProduct else {
            return "Subscription auto-renews unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings > Apple ID > Subscriptions."
        }

        let period = product.subscription.map { periodLabel(for: $0.subscriptionPeriod) } ?? "period"

        // If the product has a free trial, mention it in the notice
        if let offer = product.subscription?.introductoryOffer,
           offer.paymentMode == .freeTrial {
            let trialPeriod = periodLabel(for: offer.period)
            return "Free for \(trialPeriod), then \(product.displayPrice) per \(period). Subscription auto-renews unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings > Apple ID > Subscriptions."
        }

        return "Subscription auto-renews at \(product.displayPrice) per \(period) unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings > Apple ID > Subscriptions."
    }

    private func periodLabel(for period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:   return period.value == 1 ? "day"   : "\(period.value) days"
        case .week:  return period.value == 1 ? "week"  : "\(period.value) weeks"
        case .month: return period.value == 1 ? "month" : "\(period.value) months"
        case .year:  return period.value == 1 ? "year"  : "\(period.value) years"
        @unknown default: return "period"
        }
    }
}
