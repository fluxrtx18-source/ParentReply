import SwiftUI

struct PaywallNavBar: View {
    let isOnboarding: Bool
    var onDismiss: () -> Void

    var body: some View {
        HStack {
            if !isOnboarding {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(AppDesign.Color.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Close")
            }
            Spacer()
        }
    }
}
