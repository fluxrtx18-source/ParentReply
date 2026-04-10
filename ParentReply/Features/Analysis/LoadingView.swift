import SwiftUI
import Accessibility

struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: AppDesign.Spacing.lg) {
            ProgressView()
                .controlSize(.large)
                .tint(AppDesign.Color.accent)

            Text(message)
                .font(AppDesign.Font.body)
                .foregroundStyle(AppDesign.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            AccessibilityNotification.Announcement(message).post()
        }
    }
}

#Preview {
    LoadingView(message: "Crafting your replies...")
        .background(AppDesign.Color.background)
        .preferredColorScheme(.dark)
}
