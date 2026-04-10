import SwiftUI

/// Screen 4 — personalised solution.
/// "You told us your problems, here's exactly how we fix them."
struct PersonalisedSolutionStepView: View {
    var onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppDesign.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 52)

                    // Headline
                    Text("Here's how ParentReply\nhelps you")
                        .font(.system(.title, design: .rounded, weight: .black))
                        .foregroundStyle(AppDesign.Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)

                    Spacer().frame(height: 32)

                    // Solution items
                    VStack(spacing: 14) {
                        ForEach(PersonalisedSolutionData.items.enumerated(), id: \.element.id) { idx, item in
                            SolutionRow(item: item)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 18)
                                .animation(
                                    .easeOut(duration: 0.38).delay(0.18 + Double(idx) * 0.08),
                                    value: appeared
                                )
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 120)
                }
            }

            // Fixed CTA
            VStack(spacing: 0) {
                Divider().opacity(0.2)
                Button(action: onContinue) {
                    Text("Show me how")
                        .font(.system(.body, design: .rounded, weight: .semibold))
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
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.35).delay(0.5), value: appeared)
        }
        .scrollIndicators(.hidden)
        .task {
            if reduceMotion {
                var transaction = Transaction(animation: nil)
                transaction.disablesAnimations = true
                withTransaction(transaction) { appeared = true }
            } else {
                appeared = true
            }
        }
    }
}

// MARK: - Solution Row

// SolutionRow extracted to SolutionRow.swift
