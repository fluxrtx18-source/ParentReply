import SwiftUI
import StoreKit

struct PaywallView: View {
    var onDismiss: () -> Void = {}
    /// When `true` (shown as last onboarding step), hides the close button and
    /// shows a "Start free — 5 replies included" escape hatch below the CTA.
    var isOnboarding: Bool = false

    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss)               private var dismiss

    @State private var selectedProductID: String = SubscriptionManager.yearlyID
    @State private var isPurchasing = false
    @State private var purchaseError: String?

    private let timeline: [(icon: String, title: String, body: String)] = [
        ("lock.open.fill", "Today", "Unlock all 6 reply tones plus the situation summary for every message"),
        ("sparkles", "Instantly", "On-device AI — your messages stay private, no cloud, no waiting"),
        ("crown.fill", "Always", "Cancel anytime from your App Store subscription settings")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                navBar
                    .padding(.horizontal, 22)
                    .padding(.top, 12)

                if isOnboarding {
                    freeTrialBanner
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                }

                headline
                    .padding(.horizontal, 24)
                    .padding(.top, isOnboarding ? 16 : 28)
                    .padding(.bottom, 36)

                timelineSection
                    .padding(.bottom, 36)

                planCards
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                autoRenewalNotice
                    .padding(.bottom, 14)

                ctaButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                footnote
                    .padding(.bottom, isOnboarding ? 8 : 40)

                if isOnboarding {
                    freeEscapeButton
                        .padding(.bottom, 40)
                }
            }
        }
        .scrollIndicators(.hidden)
        .background(AppDesign.Color.background.ignoresSafeArea())
        .task {
            if subscriptionManager.products.isEmpty {
                await subscriptionManager.loadProducts()
            }
        }
        .onChange(of: subscriptionManager.isSubscribed) {
            if subscriptionManager.isSubscribed {
                if isOnboarding { onDismiss() } else { dismiss() }
            }
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            if !isOnboarding {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppDesign.Color.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Close")
            }
            Spacer()
        }
    }

    // MARK: - Free Trial Banner

    private var freeTrialBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "gift.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppDesign.Color.accent)
            Text("5 free replies included — no credit card needed")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(AppDesign.Color.accent)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppDesign.Color.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Free Escape

    private var freeEscapeButton: some View {
        Button(action: onDismiss) {
            Text("Start free — 5 replies, no subscription")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(AppDesign.Color.textSecondary)
                .underline()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    // MARK: - Headline

    private var headline: some View {
        Text(headlineAttributed)
            .font(.system(size: 32, weight: .black, design: .rounded))
            .foregroundStyle(AppDesign.Color.textPrimary)
            .lineSpacing(3)
    }

    private var headlineAttributed: AttributedString {
        var string = AttributedString("Reply smarter\nwith ParentReply Pro")
        if let range = string.range(of: "ParentReply Pro") {
            string[range].foregroundColor = UIColor(
                red: 0.05, green: 0.58, blue: 0.53, alpha: 1
            )
        }
        return string
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        HStack(alignment: .top, spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [AppDesign.Color.accent, AppDesign.Color.accent.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 54)

                VStack(spacing: 0) {
                    Spacer().frame(height: 16)
                    iconBadge(timeline[0].icon, opacity: 1.0)
                    Spacer()
                    iconBadge(timeline[1].icon, opacity: 0.80)
                    Spacer()
                    iconBadge(timeline[2].icon, opacity: 0.45)
                    Spacer().frame(height: 28)
                }
                .frame(width: 54)
            }
            .frame(width: 54, height: 260)

            VStack(alignment: .leading, spacing: 0) {
                timelineRow(title: timeline[0].title, body: timeline[0].body)
                Spacer()
                timelineRow(title: timeline[1].title, body: timeline[1].body)
                Spacer()
                timelineRow(title: timeline[2].title, body: timeline[2].body)
            }
            .frame(height: 260)
            .padding(.trailing, 6)
        }
        .padding(.horizontal, 20)
    }

    private func iconBadge(_ symbol: String, opacity: Double) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.22 * opacity))
                .frame(width: 40, height: 40)
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.white.opacity(opacity))
        }
    }

    private func timelineRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppDesign.Color.textPrimary)
            Text(body)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(AppDesign.Color.textSecondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Plan Cards

    private var planCards: some View {
        VStack(spacing: 14) {
            ForEach(subscriptionManager.products) { product in
                PlanCard(
                    product: product,
                    isSelected: selectedProductID == product.id,
                    weeklyProduct: subscriptionManager.products.first(where: { $0.id == SubscriptionManager.weeklyID })
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                        selectedProductID = product.id
                    }
                }
            }
        }
    }

    // MARK: - Auto-Renewal Notice

    private var autoRenewalNotice: some View {
        Text("Subscription auto-renews unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings > Apple ID > Subscriptions.")
            .font(.caption2)
            .foregroundStyle(AppDesign.Color.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }

    // MARK: - CTA

    private var ctaButton: some View {
        Button {
            Task { await purchase() }
        } label: {
            ZStack {
                if isPurchasing {
                    ProgressView().tint(.white).scaleEffect(1.1)
                } else {
                    VStack(spacing: 2) {
                        Text("Unlock ParentReply Pro")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
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
    }

    // MARK: - Footnote

    private var footnote: some View {
        VStack(spacing: 8) {
            Button {
                Task { await subscriptionManager.restore() }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppDesign.Color.accent)
            }

            HStack(spacing: 4) {
                if let termsURL = URL(string: "https://fluxrtx18-source.github.io/ParentReply/terms") {
                    Link("Terms of Use", destination: termsURL)
                }
                Text("·").foregroundStyle(AppDesign.Color.textSecondary)
                if let privacyURL = URL(string: "https://fluxrtx18-source.github.io/ParentReply/privacy") {
                    Link("Privacy Policy", destination: privacyURL)
                }
            }
            .font(.system(size: 11))
            .foregroundStyle(AppDesign.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
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
    }
}

// MARK: - Plan Card

private struct PlanCard: View {
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
                    Text(product.displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppDesign.Color.textPrimary)
                    Text(product.displayPrice)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(AppDesign.Color.textSecondary)
                }
                Spacer()

                if let savings = savingsBadge, isSelected {
                    Text(savings)
                        .font(.system(size: 11, weight: .black, design: .rounded))
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

    private var savingsBadge: String? {
        guard let weekly = weeklyProduct,
              product.id != SubscriptionManager.weeklyID else { return nil }
        let weeklyAnnual = (weekly.price as NSDecimalNumber).doubleValue * 52
        let productPrice = (product.price as NSDecimalNumber).doubleValue
        guard weeklyAnnual > 0 else { return nil }
        let ratio = 1 - (productPrice / weeklyAnnual)
        guard ratio > 0.05 else { return nil }
        return "SAVE \(Int((ratio * 100).rounded()))%"
    }
}
