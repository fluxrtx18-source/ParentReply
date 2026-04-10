import SwiftUI
import Accessibility

/// Screen 5 — interactive demo.
/// Shows a simulated school message being "analysed" with reply tones appearing one by one.
/// The user taps each reply to "preview" it — creating the aha moment before the paywall.
struct AppDemoStepView: View {
    var onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Phase = .reading
    @State private var visibleReplies = 0
    @State private var appeared = false
    @State private var selectedReply: Int? = nil

    private let demo = DemoMessages.message
    private let replies = DemoMessages.demoReplies

    enum Phase { case reading, repliesReady }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppDesign.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 52)

                    // Header
                    VStack(spacing: 8) {
                        Text("See it in action")
                            .font(.system(.title2, design: .rounded, weight: .black))
                            .foregroundStyle(AppDesign.Color.textPrimary)
                        Text(phase == .reading
                             ? "Reading the teacher's message..."
                             : "Tap a reply to preview it")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(AppDesign.Color.textSecondary)
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.35).delay(0.05), value: appeared)

                    Spacer().frame(height: 24)

                    // Simulated message card
                    messageCard
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.15), value: appeared)

                    Spacer().frame(height: 20)

                    // Reply cards (appear one by one)
                    if phase == .repliesReady {
                        VStack(spacing: 12) {
                            ForEach(replies.enumerated(), id: \.offset) { idx, reply in
                                if idx < visibleReplies {
                                    demoReplyCard(reply: reply, index: idx)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer().frame(height: 120)
                }
            }
            .scrollIndicators(.hidden)

            // CTA — only after all replies visible
            if visibleReplies >= replies.count {
                VStack(spacing: 0) {
                    Divider().opacity(0.2)
                    Button(action: onContinue) {
                        Text("That's amazing — continue")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
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
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .task {
            if reduceMotion {
                var transaction = Transaction(animation: nil)
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    appeared = true
                    phase = .repliesReady
                    visibleReplies = replies.count
                }
            } else {
                appeared = true
                // Simulate "reading" phase
                try? await Task.sleep(for: .seconds(1.5))
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.35)) { phase = .repliesReady }

                // Reveal replies one by one (guard avoids invalid range if array is ever empty)
                for i in replies.indices {
                    try? await Task.sleep(for: .seconds(0.5))
                    guard !Task.isCancelled else { return }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        visibleReplies = i + 1
                    }
                }
                // Notify VoiceOver that the CTA button has appeared
                AccessibilityNotification.LayoutChanged().post()
            }
        }
    }

    // MARK: - Message Card

    private var messageCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(AppDesign.Color.accent.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text(String(demo.from.prefix(1)))
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(AppDesign.Color.accent)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(demo.from)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(AppDesign.Color.textPrimary)
                    Text(demo.subject)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(AppDesign.Color.textSecondary)
                }
            }

            Text(demo.body)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(AppDesign.Color.textPrimary.opacity(0.85))
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppDesign.Color.surface)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppDesign.Color.border, lineWidth: 1)
        }
    }

    // MARK: - Demo Reply Card

    private func demoReplyCard(reply: (tone: ReplyTone, text: String), index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedReply = (selectedReply == index) ? nil : index
            }
        } label: {

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: reply.tone.icon)
                        .font(.system(size: 12))
                    Text(reply.tone.displayName.uppercased())
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .tracking(0.5)
                }
                .foregroundStyle(reply.tone.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(reply.tone.color.opacity(0.12), in: Capsule())

                Text(reply.text)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textPrimary.opacity(0.9))
                    .lineSpacing(3)
                    .lineLimit(selectedReply == index ? nil : 2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppDesign.Color.surface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        selectedReply == index ? reply.tone.color : AppDesign.Color.border,
                        lineWidth: selectedReply == index ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(reply.tone.displayName) reply: \(reply.text)")
        .accessibilityHint(selectedReply == index ? "Double-tap to collapse" : "Double-tap to expand")
    }

}
