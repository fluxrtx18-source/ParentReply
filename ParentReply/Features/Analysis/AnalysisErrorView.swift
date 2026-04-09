import SwiftUI

struct AnalysisErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Couldn't Read Message", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: onRetry)
                .buttonStyle(.bordered)
        }
    }
}
