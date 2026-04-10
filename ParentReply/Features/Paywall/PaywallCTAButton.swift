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
                        Text("Unlock ParentReply Pro")
                            .font(.system(.body, design: .rounded, weight: .bold))
                        if let product = selectedProduct {
                            Text("\(product.displayPrice) · Cancel anytime")
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
        .accessibilityLabel(isPurchasing ? "Purchasing, please wait" : "Unlock ParentReply Pro")
    }
}
