import SwiftUI

struct HomeView: View {
    @Environment(UsageTracker.self)        private var usageTracker
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @State private var selectedImage: IdentifiableImage?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppDesign.Color.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppDesign.Spacing.xl) {
                        HomeHeaderView()
                        if !subscriptionManager.isSubscribed {
                            UsageBadgeView()
                        }
                        HowItWorksCard()
                        HomeActionSection(
                            onImage: { selectedImage = IdentifiableImage(image: $0) }
                        )
                        Spacer(minLength: AppDesign.Spacing.xxl)
                    }
                    .padding(AppDesign.Spacing.md)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !subscriptionManager.isSubscribed {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Upgrade", action: { showPaywall = true })
                            .font(AppDesign.Font.subhead)
                            .foregroundStyle(AppDesign.Color.accent)
                    }
                }
            }
            .sheet(item: $selectedImage) { wrapper in
                AnalysisView(image: wrapper.image)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onForeground {
                usageTracker.refresh()
                Task { await subscriptionManager.refresh() }
            }
        }
    }
}

// MARK: - Foreground detection helper

private extension View {
    func onForeground(perform action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            action()
        }
    }
}
