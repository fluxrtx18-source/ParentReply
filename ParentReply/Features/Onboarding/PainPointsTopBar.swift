import SwiftUI

/// Back-button top bar for the pain points onboarding step.
struct PainPointsTopBar: View {
    var onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppDesign.Color.textPrimary)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("Go back")
            Spacer()
        }
        .frame(height: 32)
    }
}
