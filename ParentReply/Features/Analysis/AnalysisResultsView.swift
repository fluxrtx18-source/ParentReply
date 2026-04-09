import SwiftUI

struct AnalysisResultsView: View {
    let analysis: SchoolMessageAnalysis
    let copiedTone: ReplyTone?
    var isSubscribed: Bool = false
    let onCopy: (ReplyTone) -> Void
    var onUpgrade: () -> Void = {}

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(spacing: AppDesign.Spacing.md) {
                // D2: Situation summary is a paid feature.
                if !PaywallGate.isSummaryLocked(isSubscribed: isSubscribed) {
                    SummaryCard(summary: analysis.situationSummary)
                } else {
                    lockedSummaryCard
                }

                Text("Choose your reply")
                    .font(AppDesign.Font.headline)
                    .foregroundStyle(AppDesign.Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // D1: Only PaywallGate.freeTone is available without a subscription.
                ForEach(ReplyTone.allCases) { tone in
                    let locked = PaywallGate.isLocked(tone: tone, isSubscribed: isSubscribed)
                    ReplyCardView(
                        tone: tone,
                        replyText: analysis.reply(for: tone),
                        isCopied: copiedTone == tone,
                        isRecommended: tone == analysis.recommendedTone,
                        isLocked: locked,
                        onCopy: locked ? onUpgrade : { onCopy(tone) }
                    )
                }

                Spacer(minLength: AppDesign.Spacing.xxl)
            }
            .padding(AppDesign.Spacing.md)
        }
        .scrollIndicators(.hidden)
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Locked summary teaser (D2)

    private var lockedSummaryCard: some View {
        ZStack {
            SummaryCard(summary: analysis.situationSummary)
                .blur(radius: 8)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            Button(action: onUpgrade) {
                VStack(spacing: AppDesign.Spacing.xs) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.title2)
                        .foregroundStyle(AppDesign.Color.accent)

                    Text("Situation summary")
                        .font(AppDesign.Font.headline)
                        .foregroundStyle(AppDesign.Color.textPrimary)

                    Text("Understand what the school needs from you")
                        .font(AppDesign.Font.subhead)
                        .foregroundStyle(AppDesign.Color.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(AppDesign.Spacing.md)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.md, style: .continuous))
            }
            .accessibilityLabel("Situation summary — upgrade to unlock")
        }
        .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.md, style: .continuous))
    }
}
