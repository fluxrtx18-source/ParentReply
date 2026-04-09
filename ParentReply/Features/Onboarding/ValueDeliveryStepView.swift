import SwiftUI

/// Screen 6 — value delivery / viral moment.
/// Processing animation reveals the "your reply is ready" output.
/// Sunk cost drives conversion into the paywall on the next screen.
struct ValueDeliveryStepView: View {
    var onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Phase = .processing
    @State private var appeared = false

    private let replies = DemoMessages.demoReplies

    enum Phase { case processing, revealed }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppDesign.Color.background.ignoresSafeArea()

            switch phase {
            case .processing:
                processingView
                    .transition(.opacity)
            case .revealed:
                revealedView
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: phase)
        .task {
            if reduceMotion {
                var transaction = Transaction(animation: nil)
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    appeared = true
                    phase = .revealed
                }
            } else {
                appeared = true
                try? await Task.sleep(for: .seconds(1.8))
                guard !Task.isCancelled else { return }
                withAnimation { phase = .revealed }
            }
        }
    }

    // MARK: - Processing

    private var processingView: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppDesign.Color.accent.opacity(0.08))
                    .frame(width: 120, height: 120)
                ProgressView()
                    .scaleEffect(1.6)
                    .tint(AppDesign.Color.accent)
            }

            VStack(spacing: 8) {
                Text("Crafting your replies...")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                Text("Finding the right words for every tone")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textSecondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Revealed

    private var revealedView: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 52)

                    VStack(spacing: 10) {
                        Text("Your replies are ready!")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(AppDesign.Color.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)

                        Text("ParentReply crafted \(replies.count) tone options for you.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(AppDesign.Color.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 36)
                    }

                    Spacer().frame(height: 32)

                    // Reply preview
                    VStack(spacing: 12) {
                        ForEach(Array(replies.enumerated()), id: \.offset) { idx, reply in
                            replyPreviewRow(reply: reply, index: idx + 1)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 24)

                    statsStrip

                    Spacer().frame(height: 120)
                }
            }

            // CTA
            VStack(spacing: 0) {
                Divider().opacity(0.2)
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("Keep my replies")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
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

    // MARK: - Reply Preview Row

    private func replyPreviewRow(reply: (tone: ReplyTone, text: String), index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(reply.tone.color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: reply.tone.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(reply.tone.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(reply.tone.displayName.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(0.8)
                    .foregroundStyle(reply.tone.color)
                Text(reply.text)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "doc.on.doc")
                .font(.system(size: 12))
                .foregroundStyle(AppDesign.Color.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppDesign.Color.surface)
                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppDesign.Color.border, lineWidth: 1)
        )
    }

    // MARK: - Stats strip

    private var statsStrip: some View {
        HStack(spacing: 0) {
            StatPill(value: "6", label: "Tones")
            Divider().frame(height: 32).overlay(AppDesign.Color.border)
            StatPill(value: "1", label: "Message")
            Divider().frame(height: 32).overlay(AppDesign.Color.border)
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

// MARK: - Stat Pill

private struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(AppDesign.Color.accent)
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(AppDesign.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
