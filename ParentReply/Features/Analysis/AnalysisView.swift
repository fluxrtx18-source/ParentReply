import SwiftUI
import UIKit

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
                content
            }
            .navigationTitle("ParentReply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", action: dismiss.callAsFunction)
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

    // MARK: - Content switching

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()

        case .extractingText:
            LoadingView(message: "Reading the school message...")

        case .analyzing:
            LoadingView(message: "Crafting your replies...")

        case .complete:
            if let analysis = viewModel.analysis {
                AnalysisResultsView(
                    analysis: analysis,
                    copiedTone: viewModel.copiedTone,
                    isSubscribed: subscriptionManager.isSubscribed,
                    onCopy: { viewModel.copyReply(for: $0) },
                    onUpgrade: { showPaywall = true }
                )
            }

        case .failed(let message):
            AnalysisErrorView(message: message) {
                viewModel.reset()
                analysisTrigger.toggle()
            }
        }
    }

    // MARK: - Logic

    private func startAnalysis() async {
        await viewModel.analyze(image: image, usageTracker: usageTracker,
                                isSubscribed: subscriptionManager.isSubscribed)
    }
}
