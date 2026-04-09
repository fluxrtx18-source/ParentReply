import SwiftUI

@main
struct ParentReplyApp: App {
    @State private var usageTracker        = UsageTracker()
    @State private var subscriptionManager = SubscriptionManager()

    @AppStorage(UserDefaultsKeys.onboardingComplete) private var onboardingComplete = false

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingComplete {
                    HomeView()
                } else {
                    OnboardingContainerView()
                }
            }
            .environment(usageTracker)
            .environment(subscriptionManager)
            .preferredColorScheme(.dark)
            .task {
                await subscriptionManager.loadProducts()
            }
        }
    }
}
