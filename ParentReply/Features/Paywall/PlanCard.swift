import SwiftUI
import StoreKit

struct PlanCard: View {
    let product: Product
    let isSelected: Bool
    let weeklyProduct: Product?

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppDesign.Color.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isSelected ? AppDesign.Color.accent : AppDesign.Color.border,
                            lineWidth: isSelected ? 2 : 1.5
                        )
                }
                .shadow(
                    color: isSelected ? AppDesign.Color.accent.opacity(0.18) : .black.opacity(0.04),
                    radius: isSelected ? 14 : 4,
                    y: isSelected ? 6 : 2
                )

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(product.displayName)
                            .font(.system(.callout, design: .rounded, weight: .bold))
                            .foregroundStyle(AppDesign.Color.textPrimary)

                        if let trialText = trialBadgeText {
                            Text(trialText)
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundStyle(AppDesign.Color.accent)
                        }
                    }

                    Text(product.displayPrice)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(AppDesign.Color.textSecondary)
                }
                Spacer()

                if let savings = savingsBadge {
                    Text(savings)
                        .font(.system(.caption, design: .rounded, weight: .black))
                        .tracking(0.6)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(AppDesign.Color.accent, in: Capsule())
                }

                if isSelected {
                    Circle()
                        .fill(AppDesign.Color.accent)
                        .frame(width: 28, height: 28)
                        .overlay {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(.white)
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
    }

    // MARK: - Trial Badge

    private var trialBadgeText: String? {
        guard let offer = product.subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else { return nil }
        let period = offer.period
        switch period.unit {
        case .day:   return period.value == 1 ? "1-day trial"   : "\(period.value)-day trial"
        case .week:  return period.value == 1 ? "1-week trial"  : "\(period.value)-week trial"
        case .month: return period.value == 1 ? "1-month trial" : "\(period.value)-month trial"
        case .year:  return period.value == 1 ? "1-year trial"  : "\(period.value)-year trial"
        @unknown default: return nil
        }
    }

    // MARK: - Savings Badge

    private var savingsBadge: String? {
        guard let weekly = weeklyProduct,
              product.id != SubscriptionManager.weeklyID else { return nil }
        let weeklyPrice = (weekly.price as NSDecimalNumber).doubleValue
        let productPrice = (product.price as NSDecimalNumber).doubleValue
        guard weeklyPrice > 0 else { return nil }
        let weeks: Double = product.id == SubscriptionManager.monthlyID ? 52.0 / 12.0 : 52.0
        let weeklyEquivalent = weeklyPrice * weeks
        let ratio = 1 - (productPrice / weeklyEquivalent)
        guard ratio > 0.05 else { return nil }
        return "SAVE \(Int((ratio * 100).rounded()))%"
    }
}
