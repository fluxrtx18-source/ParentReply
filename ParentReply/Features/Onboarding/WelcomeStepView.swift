import SwiftUI

/// Screen 1 — cinematic hero with large headline, tagline, and "Get Started" CTA.
struct WelcomeStepView: View {
    var onGetStarted: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            AppDesign.Color.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App icon representation
                ZStack {
                    Circle()
                        .fill(AppDesign.Color.accent.opacity(0.12))
                        .frame(width: 140, height: 140)
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 56, weight: .medium))
                        .foregroundStyle(AppDesign.Color.accentGradient)
                }
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)

                Spacer().frame(height: 36)

                // Headline
                Text("Reply to school\nwith confidence.")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.easeOut(duration: 0.45).delay(0.25), value: appeared)

                Spacer().frame(height: 14)

                // Body
                Text("Screenshot any school message. ParentReply crafts six perfect replies — 100% on your device, totally private.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(AppDesign.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(0.35), value: appeared)

                Spacer()

                // CTA
                Button(action: onGetStarted) {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(AppDesign.Color.accentGradient, in: Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.45), value: appeared)
            }
        }
        .onAppear { appeared = true }
    }
}
