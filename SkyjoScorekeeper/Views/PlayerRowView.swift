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

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var highContrast: Bool { colorSchemeContrast == .increased }

    private var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? placeholder : trimmed
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(avatarFill)
                .frame(width: 30, height: 30)
                .overlay {
                    Text(avatarLabel)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(avatarTextColor)
                }
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: isFilled)
                .accessibilityHidden(true)

            TextField(placeholder, text: $name)
                .font(.system(.body, design: .rounded))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .accessibilityLabel(showError ? String(localized: "\(placeholder) name, required") : String(localized: "\(placeholder) name"))

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
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Remove \(displayName)"))
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 54)
        .background(showError ? Color(.systemRed).opacity(0.05) : Color.clear)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: showError)
    }

    private var avatarFill: Color {
        let base = Theme.playerColor(at: colorIndex, highContrast: highContrast)
        return isFilled ? base : base.opacity(0.15)
    }

    private var avatarTextColor: Color {
        isFilled
            ? Theme.playerTextColor(at: colorIndex, highContrast: highContrast)
            : Theme.playerColor(at: colorIndex, highContrast: highContrast)
    }
}
