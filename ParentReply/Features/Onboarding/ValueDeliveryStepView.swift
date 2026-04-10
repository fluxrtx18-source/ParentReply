import SwiftUI
import Accessibility

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
                ProcessingView()
                    .transition(.opacity)
            case .revealed:
                RepliesRevealedView(replies: replies, onContinue: onContinue)
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
                withAnimation(.easeInOut(duration: 0.4)) { phase = .revealed }
                AccessibilityNotification.Announcement("Your replies are ready").post()
            }
        }
    }
}

// MARK: - Stat Pill

// StatPill extracted to StatPill.swift
