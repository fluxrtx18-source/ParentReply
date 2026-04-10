import SwiftUI

/// Revealed view showing the reply results and CTA in the value delivery step.
struct RepliesRevealedView: View {
    let replies: [(tone: ReplyTone, text: String)]
    var onContinue: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 52)

                    VStack(spacing: 10) {
                        Text("Your replies are ready!")
                            .font(.system(.title, design: .rounded, weight: .black))
                            .foregroundStyle(AppDesign.Color.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)

                        Text("ParentReply crafted \(replies.count) tone options for you.")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppDesign.Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 36)
                    }

                    Spacer().frame(height: 32)

                    // Reply preview
                    VStack(spacing: 12) {
                        ForEach(replies.enumerated(), id: \.offset) { idx, reply in
                            ReplyPreviewRow(tone: reply.tone, text: reply.text, index: idx + 1)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 24)

                    StatsStrip()

                    Spacer().frame(height: 120)
                }
            }
            .scrollIndicators(.hidden)

            // CTA
            VStack(spacing: 0) {
                Divider().opacity(0.2)
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Keep my replies")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AppDesign.Color.accentGradient, in: Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .padding(.bottom, 20)
                .background(AppDesign.Color.background)
            }
        }
    }
}
