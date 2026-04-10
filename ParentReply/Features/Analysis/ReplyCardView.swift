import SwiftUI

/// A single tone-specific reply card. Tap anywhere to copy the reply text.
struct ReplyCardView: View {
    let tone: ReplyTone
    let replyText: String
    let isCopied: Bool
    var isRecommended: Bool = false
    var isLocked: Bool = false
    let onCopy: () -> Void

    var body: some View {
        Button(action: onCopy) {
            ReplyCardContent(
                tone: tone,
                replyText: replyText,
                isCopied: isCopied,
                isRecommended: isRecommended,
                isLocked: isLocked
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isLocked
            ? "\(tone.displayName) reply — locked"
            : "\(tone.displayName) reply: \(replyText)")
        .accessibilityHint(isLocked
            ? Text("Double-tap to upgrade")
            : isCopied ? Text("Copied to clipboard") : Text("Double-tap to copy"))
        .sensoryFeedback(.success, trigger: isCopied)
    }
}

#Preview {
    ReplyCardView(
        tone: .grateful,
        replyText: "Thank you so much for letting us know. We'll talk to our child about this and make sure they understand the importance of respectful behaviour at school.",
        isCopied: false,
        isRecommended: true,
        onCopy: {}
    )
    .padding()
    .background(AppDesign.Color.background)
    .preferredColorScheme(.dark)
}
