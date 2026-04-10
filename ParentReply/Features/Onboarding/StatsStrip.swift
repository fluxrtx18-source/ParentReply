import SwiftUI

/// Horizontal stats bar ("6 Tones · 1 Message · 0s Wait time") in the value delivery step.
struct StatsStrip: View {
    var body: some View {
        HStack(spacing: 0) {
            StatPill(value: "6", label: "Tones")
            Divider().frame(height: 32).overlay { AppDesign.Color.border }
            StatPill(value: "1", label: "Message")
            Divider().frame(height: 32).overlay { AppDesign.Color.border }
            StatPill(value: "0s", label: "Wait time")
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppDesign.Color.accent.opacity(0.06))
        )
        .padding(.horizontal, 20)
    }
}
