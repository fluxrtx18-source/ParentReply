import SwiftUI

/// Full-screen sheet that processes the screenshot and shows the results.
struct AnalysisView: View {
    let image: UIImage

    @Environment(UsageTracker.self)        private var usageTracker
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss)               private var dismiss

    @State private var viewModel = AnalysisViewModel()
    @State private var showPaywall = false
    @State private var analysisTrigger = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppDesign.Color.background.ignoresSafeArea()
                AnalysisContentView(
                    state: viewModel.state,
                    analysis: viewModel.analysis,
                    copiedTone: viewModel.copiedTone,
                    isSubscribed: subscriptionManager.isSubscribed,
                    onCopy: { viewModel.copyReply(for: $0) },
                    onUpgrade: { showPaywall = true },
                    onRetry: { viewModel.reset(); analysisTrigger.toggle() }
                )
            }
            .animation(AppDesign.Anim.standard, value: viewModel.state)
            .navigationTitle("ParentReply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(AppDesign.Color.textSecondary)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .task(id: analysisTrigger) {
                await startAnalysis()
            }
        }
    }

    // MARK: - Logic

    private func startAnalysis() async {
        await viewModel.analyze(image: image, usageTracker: usageTracker,
                                isSubscribed: subscriptionManager.isSubscribed)
    }
}
