import SwiftUI
import StoreKit

struct PaywallPlanCards: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Binding var selectedProductID: String

    var body: some View {
        VStack(spacing: 14) {
            if subscriptionManager.isLoadingProducts {
                ProgressView()
                    .tint(AppDesign.Color.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .accessibilityLabel("Loading plans")
            } else if subscriptionManager.products.isEmpty {
                VStack(spacing: 10) {
                    Text("Plans unavailable")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppDesign.Color.textSecondary)
                    Button("Try Again") {
                        Task { await subscriptionManager.loadProducts() }
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(AppDesign.Color.accent)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
            } else {
                ForEach(subscriptionManager.products) { product in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                            selectedProductID = product.id
                        }
                    } label: {
                        PlanCard(
                            product: product,
                            isSelected: selectedProductID == product.id,
                            weeklyProduct: subscriptionManager.products.first(where: { $0.id == SubscriptionManager.weeklyID })
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(product.displayName), \(product.displayPrice)")
                    .accessibilityAddTraits(selectedProductID == product.id ? .isSelected : [])
                }
            }
        }
    }
}
