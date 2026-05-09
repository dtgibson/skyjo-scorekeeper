import SwiftUI

struct PlayerRowView: View {
    @Binding var name: String
    let placeholder: String
    let avatarLabel: String
    let colorIndex: Int
    let isFilled: Bool
    let showError: Bool
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isFilled
                      ? Theme.playerColor(at: colorIndex)
                      : Theme.playerColor(at: colorIndex).opacity(0.15))
                .frame(width: 30, height: 30)
                .overlay {
                    Text(avatarLabel)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            isFilled
                                ? Theme.playerTextColor(at: colorIndex)
                                : Theme.playerColor(at: colorIndex)
                        )
                }
                .animation(.easeInOut(duration: 0.15), value: isFilled)

            TextField(placeholder, text: $name)
                .font(.system(size: 17, design: .rounded))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)

            if canRemove {
                Button(action: onRemove) {
                    Circle()
                        .fill(Color(.systemRed))
                        .frame(width: 24, height: 24)
                        .overlay {
                            Rectangle()
                                .fill(.white)
                                .frame(width: 12, height: 2)
                                .clipShape(Capsule())
                        }
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 54)
        .background(showError ? Color(.systemRed).opacity(0.05) : Color.clear)
        .animation(.easeInOut(duration: 0.15), value: showError)
    }
}
