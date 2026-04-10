import SwiftUI

struct MainActionButtonLabel: View {
    var isLoading: Bool = false

    var body: some View {
        HStack(spacing: AppDesign.Spacing.sm) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(AppDesign.Font.headline)
                Text("Choose Screenshot")
                    .font(AppDesign.Font.headline)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(AppDesign.Color.accentGradient)
        .clipShape(.rect(cornerRadius: AppDesign.Radius.md))
    }
}

#Preview("Idle") {
    MainActionButtonLabel(isLoading: false)
        .padding()
        .background(AppDesign.Color.background)
        .preferredColorScheme(.dark)
}

#Preview("Loading") {
    MainActionButtonLabel(isLoading: true)
        .padding()
        .background(AppDesign.Color.background)
        .preferredColorScheme(.dark)
}
