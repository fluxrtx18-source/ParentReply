/// Encodes the D1 + D2 paywall gate rules as pure functions so they can be
/// unit-tested independently of the SwiftUI view layer.
///
/// **D1** (tone gate): Only `.grateful` is available to free users.
/// All other tones require an active subscription.
///
/// **D2** (summary gate): The situation summary card is a paid feature.
/// Free users see a blurred teaser that communicates the value without
/// revealing the content.
enum PaywallGate {

    // MARK: - Free tier constant

    /// The single tone available without a subscription (D1).
    static let freeTone: ReplyTone = .grateful

    // MARK: - D1: Tone locking

    /// Returns `true` when `tone` should be locked for the given subscription state.
    static func isLocked(tone: ReplyTone, isSubscribed: Bool) -> Bool {
        !isSubscribed && tone != freeTone
    }

    // MARK: - D2: Summary locking

    /// Returns `true` when the situation summary card should be locked.
    static func isSummaryLocked(isSubscribed: Bool) -> Bool {
        !isSubscribed
    }
}
