import SwiftUI

struct HowItWorksCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.md) {
            Text("How it works")
                .font(AppDesign.Font.headline)
                .foregroundStyle(AppDesign.Color.textPrimary)

            StepRowView(number: 1, icon: "camera.viewfinder",    text: "Screenshot a school message from email, ClassDojo, or Remind")
            StepRowView(number: 2, icon: "eye.fill",             text: "ParentReply reads the message on-device — privately")
            StepRowView(number: 3, icon: "text.bubble.fill",     text: "Get six replies in different tones. Tap one to copy.")
        }
        .padding(AppDesign.Spacing.md)
        .background(AppDesign.Color.surface)
        .clipShape(.rect(cornerRadius: AppDesign.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.Radius.md)
                .strokeBorder(AppDesign.Color.border, lineWidth: 1)
        }
    }
}
