import SwiftUI

struct HomeView: View {
    @Environment(UsageTracker.self)        private var usageTracker
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.scenePhase)             private var scenePhase

    private static let privacyURL = URL(string: "https://fluxrtx18-source.github.io/ParentReply/privacy")!
    private static let termsURL   = URL(string: "https://fluxrtx18-source.github.io/ParentReply/terms")!

    @State private var selectedImage: IdentifiableImage?
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppDesign.Color.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppDesign.Spacing.xl) {
                        if subscriptionManager.hasBillingIssue {
                            BillingIssueBanner()
                        }
                        HomeHeaderView()
                        if !subscriptionManager.isSubscribed {
                            UsageBadgeView()
                        }
                        HowItWorksCard()
                        HomeActionSection(
                            onImage: { selectedImage = IdentifiableImage(image: $0) }
                        )
                        HStack(spacing: 4) {
                            Link("Privacy Policy", destination: Self.privacyURL)
                            Text("·").foregroundStyle(AppDesign.Color.textSecondary)
                            Link("Terms of Use", destination: Self.termsURL)
                        }
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppDesign.Color.textSecondary)

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
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else { return }
                usageTracker.refresh()
                Task { await subscriptionManager.refresh() }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(UsageTracker())
        .environment(SubscriptionManager())
        .preferredColorScheme(.dark)
}
