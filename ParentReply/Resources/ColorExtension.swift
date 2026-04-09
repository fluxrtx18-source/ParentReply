import SwiftUI

// MARK: - Hex color init

extension Color {
    /// Init from a hex string like "#0D9488" or "0D9488"
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        let scanned = Scanner(string: cleaned).scanHexInt64(&value)
        #if DEBUG
        assert(scanned && cleaned.count == 6,
               "Color(hex:) received invalid hex string: '\(hex)'")
        #endif

        guard scanned, cleaned.count == 6 else {
            self.init(red: 0.05, green: 0.58, blue: 0.53)
            return
        }

        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8)  & 0xFF) / 255
        let b = Double(value          & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
