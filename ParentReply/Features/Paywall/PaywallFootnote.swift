import SwiftUI

struct PaywallFootnote: View {
    var onRestore: () -> Void
    let termsURL: URL
    let privacyURL: URL

    var body: some View {
        VStack(spacing: 8) {
            Button(action: onRestore) {
                Text("Restore Purchases")
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(AppDesign.Color.accent)
            }

            HStack(spacing: 4) {
                Link("Terms of Use", destination: termsURL)
                Text("·").foregroundStyle(AppDesign.Color.textSecondary)
                Link("Privacy Policy", destination: privacyURL)
            }
            .font(.system(.caption2))
            .foregroundStyle(AppDesign.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
