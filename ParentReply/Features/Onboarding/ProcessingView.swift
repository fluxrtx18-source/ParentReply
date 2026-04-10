import SwiftUI

/// Full-screen processing animation shown during the value delivery step.
struct ProcessingView: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppDesign.Color.accent.opacity(0.08))
                    .frame(width: 120, height: 120)
                ProgressView()
                    .scaleEffect(1.6)
                    .tint(AppDesign.Color.accent)
            }

            VStack(spacing: 8) {
                Text("Crafting your replies...")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                Text("Finding the right words for every tone")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textSecondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
