import SwiftUI

/// Displays the situation summary at the top of the results screen.
struct SummaryCard: View {
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppDesign.Spacing.sm) {
            Label("What's happening", systemImage: "doc.text.magnifyingglass")
                .font(AppDesign.Font.headline)
                .foregroundStyle(AppDesign.Color.accent)

            Text(summary)
                .font(AppDesign.Font.body)
                .foregroundStyle(AppDesign.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDesign.Spacing.md)
        .background(AppDesign.Color.surface)
        .clipShape(.rect(cornerRadius: AppDesign.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.Radius.md)
                .strokeBorder(AppDesign.Color.accent.opacity(0.35), lineWidth: 1)
        }
    }
}

#Preview {
    SummaryCard(summary: "Ms. Thompson has flagged that Jake had difficulty staying focused during today's lesson and was redirected several times. She is looking for a collaborative response from the parent.")
        .padding()
        .background(AppDesign.Color.background)
        .preferredColorScheme(.dark)
}
