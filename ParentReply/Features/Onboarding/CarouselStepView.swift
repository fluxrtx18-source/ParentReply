import SwiftUI

/// Screen 2 — auto-advancing feature carousel with page dots.
struct CarouselStepView: View {
    var onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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

                // Page dots (decorative — TabView handles page accessibility)
                HStack(spacing: 8) {
                    ForEach(cards.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? AppDesign.Color.accent : AppDesign.Color.border)
                            .frame(width: i == currentPage ? 20 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 16)
                .accessibilityHidden(true)

                Spacer()

                // CTA
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(.body, design: .rounded, weight: .semibold))
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
            if reduceMotion {
                var transaction = Transaction(animation: nil)
                transaction.disablesAnimations = true
                withTransaction(transaction) { appeared = true }
            } else {
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
}

// MARK: - Feature Card Item

// FeatureCardItemView extracted to FeatureCardItemView.swift
