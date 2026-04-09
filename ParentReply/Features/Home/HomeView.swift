import SwiftUI

struct HomeView: View {
    @Environment(UsageTracker.self)        private var usageTracker
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.scenePhase)             private var scenePhase

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
            .onChange(of: scenePhase) {
                guard scenePhase == .active else { return }
                usageTracker.refresh()
                Task { await subscriptionManager.refresh() }
            }
        }
    }
}
