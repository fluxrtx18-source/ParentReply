import SwiftUI

/// Root onboarding container.
/// Owns the 7-step state machine and cinematic slide transitions.
/// Writes `onboardingComplete = true` to AppStorage when the user finishes.
struct OnboardingContainerView: View {
    @AppStorage(UserDefaultsKeys.onboardingComplete) private var onboardingComplete = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var step: OnboardingStep = .welcome

    var body: some View {
        ZStack {
            AppDesign.Color.background.ignoresSafeArea()

            switch step {
            case .welcome:
                WelcomeStepView {
                    advance(to: .carousel)
                }
                .transition(welcomeTransition)

            case .carousel:
                CarouselStepView {
                    advance(to: .painPoints)
                }
                .transition(slideTransition)

            case .painPoints:
                PainPointsStepView(
                    onBack: { retreat(to: .carousel) },
                    onContinue: { _ in
                        advance(to: .solution)
                    }
                )
                .transition(slideTransition)

            case .solution:
                PersonalisedSolutionStepView {
                    advance(to: .demo)
                }
                .transition(slideTransition)

            case .demo:
                AppDemoStepView {
                    advance(to: .valueDelivery)
                }
                .transition(slideTransition)

            case .valueDelivery:
                ValueDeliveryStepView {
                    advance(to: .paywall)
                }
                .transition(slideTransition)

            case .paywall:
                PaywallView(onDismiss: completeOnboarding, isOnboarding: true)
                    .transition(slideTransition)
            }
        }
    }

    // MARK: - Transitions

    private var welcomeTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity,
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private var slideTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
              )
    }

    // MARK: - Navigation

    private func advance(to next: OnboardingStep) {
        withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .easeInOut(duration: 0.38)) {
            step = next
        }
    }

    private func retreat(to prev: OnboardingStep) {
        withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .easeInOut(duration: 0.32)) {
            step = prev
        }
    }

    private func completeOnboarding() {
        withAnimation(.easeOut(duration: 0.3)) {
            onboardingComplete = true
        }
    }
}
