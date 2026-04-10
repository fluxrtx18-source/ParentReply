import SwiftUI

struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .black))
                .foregroundStyle(AppDesign.Color.accent)
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(AppDesign.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}
