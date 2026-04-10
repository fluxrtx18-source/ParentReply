import SwiftUI

struct PaywallHeadline: View {
    var body: some View {
        Text(attributed)
            .font(.system(.largeTitle, design: .rounded, weight: .black))
            .foregroundStyle(AppDesign.Color.textPrimary)
            .lineSpacing(3)
    }

    private var attributed: AttributedString {
        var string = AttributedString("Reply smarter\nwith ParentReply Pro")
        if let range = string.range(of: "ParentReply Pro") {
            string[range].foregroundColor = AppDesign.Color.accent
        }
        return string
    }
}
