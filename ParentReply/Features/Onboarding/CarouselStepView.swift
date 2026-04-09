import SwiftUI

/// Screen 2 — auto-advancing feature carousel with page dots.
struct CarouselStepView: View {
    var onContinue: () -> Void

    @State private var currentPage = 0
    @State private var appeared = false
    @State private var userSwiped = false

    private let cards = FeatureCard.all
    private let autoAdvanceInterval: Duration = .seconds(3.5)

    var body: some View {
        ZStack {
            AppDesign.Color.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                // Feature carousel
                TabView(selection: $currentPage) {
                    ForEach(cards.indices, id: \.self) { i in
                        FeatureCardItemView(card: cards[i])
                            .tag(i)
                            .padding(.horizontal, 28)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 340)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
                .onChange(of: currentPage) { _, _ in
                    userSwiped = true
                }

                // Page dots
                HStack(spacing: 8) {
                    ForEach(cards.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? AppDesign.Color.accent : AppDesign.Color.border)
                            .frame(width: i == currentPage ? 20 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 16)

                Spacer()

                // CTA
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(AppDesign.Color.accentGradient, in: Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.35).delay(0.2), value: appeared)
            }
        }
        .task {
            appeared = true
            while !Task.isCancelled {
                try? await Task.sleep(for: autoAdvanceInterval)
                guard !Task.isCancelled, !userSwiped else { break }
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentPage = (currentPage + 1) % cards.count
                }
            }
        }
    }
}

// MARK: - Feature Card Item

private struct FeatureCardItemView: View {
    let card: FeatureCard

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: card.accentHex).opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: card.icon)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color(hex: card.accentHex))
            }

            VStack(spacing: 8) {
                Text(card.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(hex: card.accentHex))
                    .tracking(1.2)
                    .textCase(.uppercase)

                Text(card.headline)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text(card.body)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 8)
            }

            Spacer()
        }
        .padding(.top, 28)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppDesign.Color.surface)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(AppDesign.Color.border, lineWidth: 1)
        )
    }
}
