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
                    LockedSummaryCard(onUpgrade: onUpgrade)
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
                        replyText: locked ? "" : analysis.reply(for: tone),
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

}
