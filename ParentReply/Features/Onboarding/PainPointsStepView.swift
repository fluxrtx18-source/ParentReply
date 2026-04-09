import SwiftUI

/// Screen 3 — multi-select pain points.
/// "Continue" is always enabled — user can skip without selecting anything.
struct PainPointsStepView: View {
    var onBack: () -> Void
    var onContinue: ([String]) -> Void

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
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)
                    .animation(.easeOut(duration: 0.3).delay(0.05), value: appeared)

                Spacer().frame(height: 8)

                Text("Pick all that apply")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.1), value: appeared)

                Spacer().frame(height: 16)

                // Option list
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(OnboardingPainPoints.options.enumerated()), id: \.element) { idx, option in
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
            }

            // Fixed CTA
            VStack(spacing: 0) {
                Divider().opacity(0.2)
                Button {
                    onContinue(Array(selected))
                } label: {
                    Text("Continue")
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
        }
        .onAppear { appeared = true }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppDesign.Color.textPrimary)
            }
            .frame(width: 32)
            .accessibilityLabel("Go back")
            Spacer()
        }
        .frame(height: 32)
    }
}

// MARK: - Pain Point Card

private struct PainPointCard: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? AppDesign.Color.accent : Color.clear)
                        .frame(width: 22, height: 22)
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            isSelected ? AppDesign.Color.accent : AppDesign.Color.border,
                            lineWidth: isSelected ? 0 : 1.5
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)

                Text(text)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(isSelected ? AppDesign.Color.accent : AppDesign.Color.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(isSelected ? AppDesign.Color.accent.opacity(0.07) : AppDesign.Color.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13)
                    .strokeBorder(
                        isSelected ? AppDesign.Color.accent : AppDesign.Color.border,
                        lineWidth: isSelected ? 1.8 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
