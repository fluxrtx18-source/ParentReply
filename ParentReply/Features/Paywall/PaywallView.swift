import SwiftUI
import StoreKit

struct PaywallView: View {
    var onDismiss: () -> Void = {}
    /// When `true` (shown as last onboarding step), hides the close button and
    /// shows a "Start free — 5 replies included" escape hatch below the CTA.
    var isOnboarding: Bool = false

    // MARK: - Constants
    private static let termsURL   = URL(string: "https://fluxrtx18-source.github.io/ParentReply/terms")!
    private static let privacyURL = URL(string: "https://fluxrtx18-source.github.io/ParentReply/privacy")!

    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss)               private var dismiss

    @State private var selectedProductID: String = SubscriptionManager.yearlyID
    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @State private var showPurchaseError = false
    @State private var showRestoreAlert  = false

    private let timeline: [(icon: String, title: String, body: String)] = [
        ("lock.open.fill", "Today", "Perfect reply in seconds — 6 tones to match any school situation"),
        ("sparkles", "Private", "100% on-device AI — your messages never leave your phone"),
        ("crown.fill", "Risk-free", "Try free, cancel anytime from App Store settings")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PaywallNavBar(isOnboarding: isOnboarding, onDismiss: { dismiss() })
                    .padding(.horizontal, 22)
                    .padding(.top, 12)

                if isOnboarding {
                    PaywallFreeTrialBanner()
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                }

                PaywallHeadline()
                    .padding(.horizontal, 24)
                    .padding(.top, isOnboarding ? 16 : 28)
                    .padding(.bottom, 36)

                PaywallTimelineSection(timeline: timeline)
                    .padding(.bottom, 36)

                PaywallPlanCards(selectedProductID: $selectedProductID)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                PaywallAutoRenewalNotice(selectedProduct: selectedProduct)
                    .padding(.bottom, 14)

                PaywallCTAButton(
                    isPurchasing: isPurchasing,
                    selectedProduct: selectedProduct,
                    onPurchase: { Task { await purchase() } }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

                if subscriptionManager.hasPendingTransaction {
                    PaywallPendingBanner()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)
                }

                PaywallFootnote(
                    onRestore: {
                        Task {
                            await subscriptionManager.restore()
                            purchaseError = subscriptionManager.purchaseError
                        }
                    },
                    termsURL: Self.termsURL,
                    privacyURL: Self.privacyURL
                )
                .padding(.bottom, isOnboarding ? 8 : 40)

                if isOnboarding {
                    PaywallFreeEscapeButton(onDismiss: onDismiss)
                        .padding(.bottom, 40)
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(AppDesign.Color.background.ignoresSafeArea())
        .task {
            if subscriptionManager.products.isEmpty {
                await subscriptionManager.loadProducts()
                if subscriptionManager.products.isEmpty {
                    purchaseError = subscriptionManager.purchaseError
                }
            }
        }
        .onChange(of: subscriptionManager.isSubscribed) { _, isSubscribed in
            if isSubscribed {
                if isOnboarding { onDismiss() } else { dismiss() }
            }
        }
        .onChange(of: subscriptionManager.products) { _, products in
            if !products.contains(where: { $0.id == selectedProductID }),
               let first = products.first {
                selectedProductID = first.id
            }
        }
        .onChange(of: purchaseError) { _, error in
            showPurchaseError = error != nil
        }
        .onChange(of: subscriptionManager.restoreMessage) { _, message in
            showRestoreAlert = message != nil
        }
        .alert("Purchase Failed", isPresented: $showPurchaseError) {
            Button("OK", role: .cancel) { purchaseError = nil }
        } message: {
            Text(purchaseError ?? "")
        }
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) { subscriptionManager.restoreMessage = nil }
        } message: {
            Text(subscriptionManager.restoreMessage ?? "")
        }
    }

    // MARK: - Helpers

    private var selectedProduct: Product? {
        subscriptionManager.products.first(where: { $0.id == selectedProductID })
    }

    @MainActor
    private func purchase() async {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        await subscriptionManager.purchase(product)
        purchaseError = subscriptionManager.purchaseError
    }
}

#Preview("Paywall — sheet") {
    PaywallView(onDismiss: {}, isOnboarding: false)
        .environment(SubscriptionManager())
        .preferredColorScheme(.dark)
}

#Preview("Paywall — onboarding") {
    PaywallView(onDismiss: {}, isOnboarding: true)
        .environment(SubscriptionManager())
        .preferredColorScheme(.dark)
}
