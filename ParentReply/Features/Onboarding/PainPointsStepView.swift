import SwiftUI

/// Screen 3 — multi-select pain points.
/// "Continue" is always enabled — user can skip without selecting anything.
struct PainPointsStepView: View {
    var onBack: () -> Void
    var onContinue: ([String]) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selected: Set<String> = []
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppDesign.Color.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with back button
                topBar
                    .padding(.top, 12)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 24)

                // Headline
                Text(OnboardingPainPoints.headline)
                    .font(.system(.title2, design: .rounded, weight: .black))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)
                    .animation(.easeOut(duration: 0.3).delay(0.05), value: appeared)

                Spacer().frame(height: 8)

                Text("Pick all that apply")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.1), value: appeared)

                Spacer().frame(height: 16)

                // Option list
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(OnboardingPainPoints.options.enumerated(), id: \.element) { idx, option in
                            PainPointCard(
                                text: option,
                                isSelected: selected.contains(option)
                            ) {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                    if selected.contains(option) {
                                        selected.remove(option)
                                    } else {
                                        selected.insert(option)
                                    }
                                }
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 14)
                            .animation(
                                .easeOut(duration: 0.3).delay(0.12 + Double(idx) * 0.04),
                                value: appeared
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 110)
                }
                .scrollIndicators(.hidden)
            }

            // Fixed CTA
            VStack(spacing: 0) {
                Divider().opacity(0.2)
                Button {
                    onContinue(Array(selected))
                } label: {
                    Text("Continue")
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
        }
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

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppDesign.Color.textPrimary)
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("Go back")
            Spacer()
        }
        .frame(height: 32)
    }
}

// MARK: - Pain Point Card

// PainPointCard extracted to PainPointCard.swift
