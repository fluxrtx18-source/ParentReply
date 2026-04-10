import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        VStack(spacing: AppDesign.Spacing.sm) {
            Text("ParentReply")
                .font(AppDesign.Font.largeTitle)
                .foregroundStyle(AppDesign.Color.accentGradient)

            Text("Know what to say.")
                .font(AppDesign.Font.title2)
                .foregroundStyle(AppDesign.Color.textPrimary)

            Text("Share a screenshot of any school message and get six reply options — crafted for every situation.")
                .font(AppDesign.Font.body)
                .foregroundStyle(AppDesign.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppDesign.Spacing.lg)
    }
}

#Preview {
    HomeHeaderView()
        .padding()
        .background(AppDesign.Color.background)
        .preferredColorScheme(.dark)
}
