import SwiftUI
import StoreKit

struct PaywallCTAButton: View {
    let isPurchasing: Bool
    let selectedProduct: Product?
    var onPurchase: () -> Void

    var body: some View {
        Button(action: onPurchase) {
            ZStack {
                if isPurchasing {
                    ProgressView().tint(.white).scaleEffect(1.1)
                } else {
                    VStack(spacing: 2) {
                        Text(ctaTitle)
                            .font(.system(.body, design: .rounded, weight: .bold))
                        if let subtitle = ctaSubtitle {
                            Text(subtitle)
                                .font(.caption)
                                .opacity(0.8)
                        }
                    }
                    .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(AppDesign.Color.accentGradient, in: RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isPurchasing || selectedProduct == nil)
        .scaleEffect(isPurchasing ? 0.97 : 1)
        .animation(.easeInOut(duration: 0.15), value: isPurchasing)
        .accessibilityLabel(isPurchasing ? "Purchasing, please wait" : ctaTitle)
    }

    // MARK: - Trial-Aware Copy

    /// Whether the currently selected product has an introductory offer (free trial).
    private var hasTrial: Bool {
        selectedProduct?.subscription?.introductoryOffer != nil
    }

    private var trialDuration: String? {
        guard let offer = selectedProduct?.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else { return nil }
        let period = offer.period
        switch period.unit {
        case .day:   return period.value == 1 ? "1 day"   : "\(period.value) days"
        case .week:  return period.value == 1 ? "1 week"  : "\(period.value) weeks"
        case .month: return period.value == 1 ? "1 month" : "\(period.value) months"
        case .year:  return period.value == 1 ? "1 year"  : "\(period.value) years"
        @unknown default: return nil
        }
    }

    private var ctaTitle: String {
        if let duration = trialDuration {
            return "Try Free for \(duration)"
        }
        return "Unlock ParentReply Pro"
    }

    private var ctaSubtitle: String? {
        guard let product = selectedProduct else { return nil }
        if hasTrial {
            return "Then \(product.displayPrice) · Cancel anytime"
        }
        return "\(product.displayPrice) · Cancel anytime"
    }
}
