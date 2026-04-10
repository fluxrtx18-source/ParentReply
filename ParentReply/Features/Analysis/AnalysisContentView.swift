import SwiftUI

/// Switches between idle / loading / results / error states for the analysis sheet.
/// Extracted from AnalysisView so SwiftUI has a stable structural identity for this subtree.
struct AnalysisContentView: View {
    let state: AnalysisViewModel.State
    let analysis: SchoolMessageAnalysis?
    let copiedTone: ReplyTone?
    let isSubscribed: Bool
    let onCopy: (ReplyTone) -> Void
    let onUpgrade: () -> Void
    let onRetry: () -> Void

    var body: some View {
        switch state {
        case .idle:
            EmptyView()

        case .extractingText:
            LoadingView(message: "Reading the school message...")

        case .analyzing:
            LoadingView(message: "Crafting your replies...")

        case .complete:
            if let analysis {
                AnalysisResultsView(
                    analysis: analysis,
                    copiedTone: copiedTone,
                    isSubscribed: isSubscribed,
                    onCopy: onCopy,
                    onUpgrade: onUpgrade
                )
            }

        case .failed(let message):
            AnalysisErrorView(message: message, onRetry: onRetry)
        }
    }
}
