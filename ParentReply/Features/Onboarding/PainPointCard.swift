import SwiftUI

struct PainPointCard: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? AppDesign.Color.accent : Color.clear)
                        .frame(width: 22, height: 22)
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            isSelected ? AppDesign.Color.accent : AppDesign.Color.border,
                            lineWidth: isSelected ? 0 : 1.5
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)

                Text(text)
                    .font(.system(.subheadline, design: .rounded, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? AppDesign.Color.accent : AppDesign.Color.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .fill(isSelected ? AppDesign.Color.accent.opacity(0.07) : AppDesign.Color.surface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 13)
                    .strokeBorder(
                        isSelected ? AppDesign.Color.accent : AppDesign.Color.border,
                        lineWidth: isSelected ? 1.8 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
