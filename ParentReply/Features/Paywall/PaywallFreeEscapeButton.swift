import SwiftUI

struct PaywallFreeEscapeButton: View {
    var onDismiss: () -> Void

    var body: some View {
        Button(action: onDismiss) {
            Text("Start free — 5 replies, no subscription")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppDesign.Color.textSecondary)
                .underline()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }
}
