import SwiftUI

struct PaywallHeadline: View {
    var body: some View {
        Text(attributed)
            .font(.system(.largeTitle, design: .rounded, weight: .black))
            .foregroundStyle(AppDesign.Color.textPrimary)
            .lineSpacing(3)
    }

    private var attributed: AttributedString {
        var string = AttributedString("Never struggle with\nschool replies again")
        if let range = string.range(of: "school replies") {
            string[range].foregroundColor = AppDesign.Color.accent
        }
        return string
    }
}
