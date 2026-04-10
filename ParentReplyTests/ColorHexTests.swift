import Testing
import SwiftUI
import UIKit
@testable import ParentReply

/// Tests for `Color(hex:)` — used at runtime to render `FeatureCard` accent colours.
///
/// Note: `Color(hex:)` contains a DEBUG-only `assert` that terminates the process for
/// invalid input strings. These tests therefore cover only valid hex strings and the
/// real-data paths used by the app. Fallback-path behaviour is documented in
/// `ColorExtension.swift` as a code-path comment.
@Suite("Color(hex:) — hex string parsing")
struct ColorHexTests {

    // MARK: - Format variants

    @Test("Parses hex string with hash prefix without crashing")
    func parsesWithHashPrefix() {
        // Hash-prefixed format used by FeatureCard.accentHex values
        let _ = Color(hex: "#0D9488")
        let _ = Color(hex: "#10B3D1")
        let _ = Color(hex: "#D97706")
    }

    @Test("Parses hex string without hash prefix without crashing")
    func parsesWithoutHashPrefix() {
        let _ = Color(hex: "0D9488")
    }

    // MARK: - Real app data

    @Test("All FeatureCard accentHex values are well-formed and parse without crash")
    func featureCardHexValuesParseCleanly() {
        for card in FeatureCard.all {
            let cleaned = card.accentHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            #expect(cleaned.count == 6,
                    "FeatureCard '\(card.headline)' has malformed accentHex: '\(card.accentHex)'")
            let _ = Color(hex: card.accentHex)
        }
    }

    // MARK: - Boundary values (valid input)

    @Test("Color(hex: '000000') produces black")
    func blackHex() {
        let color = Color(hex: "000000")
        let ui = UIColor(color)
        var r: CGFloat = -1, g: CGFloat = -1, b: CGFloat = -1, a: CGFloat = -1
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 0.0 && g == 0.0 && b == 0.0,
                "Color(hex: '000000') should be black; got r=\(r) g=\(g) b=\(b)")
    }

    @Test("Color(hex: 'FFFFFF') produces white")
    func whiteHex() {
        let color = Color(hex: "FFFFFF")
        let ui = UIColor(color)
        var r: CGFloat = -1, g: CGFloat = -1, b: CGFloat = -1, a: CGFloat = -1
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 1.0 && g == 1.0 && b == 1.0,
                "Color(hex: 'FFFFFF') should be white; got r=\(r) g=\(g) b=\(b)")
    }
}
