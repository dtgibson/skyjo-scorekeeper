import SwiftUI

struct ScoreEntrySheet: View {
    @ObservedObject var session: GameSession
    let onCommit: ([UUID: Int], UUID?) -> Void

    @State private var rawInputs: [UUID: String] = [:]
    @State private var negativeInputs: [UUID: Bool] = [:]
    @State private var skyjoPlayerID: UUID? = nil
    @State private var skyjoAnswered = false
    @State private var focusedPlayer: UUID?

    private var entries: [UUID: Int] {
        Dictionary(uniqueKeysWithValues: session.players.compactMap { player in
            guard let text = rawInputs[player.id], !text.isEmpty, let value = Int(text) else { return nil }
            let isNeg = negativeInputs[player.id] ?? false
            return (player.id, isNeg ? -value : value)
        })
    }

    private var allFilled: Bool {
        session.players.allSatisfy { entries[$0.id] != nil }
    }

    private var canConfirm: Bool { allFilled && skyjoAnswered }

    private func minOtherScore(excluding playerID: UUID) -> Int? {
        guard allFilled else { return nil }
        return entries.filter { $0.key != playerID }.values.min()
    }

    var body: some View {
        VStack(spacing: 0) {
            handle

            ScrollView {
                VStack(spacing: 20) {
                    scoresSection
                    skyjoSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .frame(maxWidth: Theme.contentMaxWidth)
                .frame(maxWidth: .infinity)
            }

            Divider()

            numpad
                .frame(maxWidth: Theme.contentMaxWidth)
                .frame(maxWidth: .infinity)

            confirmButton
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .frame(maxWidth: Theme.contentMaxWidth)
                .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { focusedPlayer = session.players.first?.id }
    }

    // MARK: - Handle

    private var handle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(.tertiaryLabel))
            .frame(width: 36, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .accessibilityHidden(true)
    }

    // MARK: - Scores

    private var scoresSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ROUND \(session.currentRoundNumber) SCORES")
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(Array(session.players.enumerated()), id: \.element.id) { index, player in
                    ScoreInputRow(
                        player: player,
                        colorIndex: index,
                        digits: rawInputs[player.id] ?? "",
                        isNegative: negativeInputs[player.id] ?? false,
                        doublingPreview: doublingPreview(for: player.id),
                        isFocused: focusedPlayer == player.id,
                        onTap: { focusedPlayer = player.id }
                    )
                    if index < session.players.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        }
    }

    // MARK: - Skyjo question

    private var skyjoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHO ENDED THE ROUND?")
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                ForEach(Array(session.players.enumerated()), id: \.element.id) { index, player in
                    SkyjoChip(
                        player: player,
                        colorIndex: index,
                        isSelected: skyjoPlayerID == player.id,
                        onTap: {
                            skyjoPlayerID = player.id
                            skyjoAnswered = true
                        }
                    )
                }
                SkyjoChip(
                    label: String(localized: "Skip"),
                    isNobody: true,
                    isSelected: skyjoAnswered && skyjoPlayerID == nil,
                    onTap: {
                        skyjoPlayerID = nil
                        skyjoAnswered = true
                    }
                )
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        }
    }

    // MARK: - Numpad

    private enum NumpadKey: Equatable {
        case digit(Int), toggle, backspace
    }

    private var numpad: some View {
        VStack(spacing: 4) {
            numpadRow([.digit(7), .digit(8), .digit(9)])
            numpadRow([.digit(4), .digit(5), .digit(6)])
            numpadRow([.digit(1), .digit(2), .digit(3)])
            numpadRow([.toggle, .digit(0), .backspace])
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func numpadRow(_ keys: [NumpadKey]) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<keys.count, id: \.self) { numpadButton(keys[$0]) }
        }
    }

    @ViewBuilder
    private func numpadButton(_ key: NumpadKey) -> some View {
        let isNegActive = focusedPlayer.flatMap { negativeInputs[$0] } ?? false
        let enabled = focusedPlayer != nil

        Button {
            guard let id = focusedPlayer else { return }
            switch key {
            case .digit(let n):
                let current = rawInputs[id] ?? ""
                guard current.count < 3 else { return }
                rawInputs[id] = (current == "0") ? "\(n)" : current + "\(n)"
            case .toggle:
                negativeInputs[id] = !(negativeInputs[id] ?? false)
            case .backspace:
                rawInputs[id] = String((rawInputs[id] ?? "").dropLast())
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(key == .toggle && isNegActive
                          ? Color(.systemRed).opacity(0.12)
                          : Color(.secondarySystemFill))

                switch key {
                case .digit(let n):
                    Text("\(n)")
                        .font(.system(.title2, design: .rounded, weight: .medium))
                        .foregroundStyle(Color(.label))
                case .toggle:
                    Text("+/\u{2212}")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(isNegActive ? Color(.systemRed) : Color(.label))
                case .backspace:
                    Image(systemName: "delete.backward")
                        .font(.system(.callout, weight: .medium))
                        .foregroundStyle(Color(.label))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
        .accessibilityLabel(numpadKeyLabel(key, isNegActive: isNegActive))
    }

    private func numpadKeyLabel(_ key: NumpadKey, isNegActive: Bool) -> String {
        switch key {
        case .digit(let n): return "\(n)"
        case .toggle: return isNegActive
            ? String(localized: "Toggle to positive")
            : String(localized: "Toggle negative")
        case .backspace: return String(localized: "Delete")
        }
    }

    // MARK: - Confirm button

    private var confirmButton: some View {
        Button {
            onCommit(entries, skyjoPlayerID)
        } label: {
            Text("Confirm Round \(session.currentRoundNumber)")
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 58)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: canConfirm))
        .disabled(!canConfirm)
    }

    // MARK: - Helpers

    private func doublingPreview(for playerID: UUID) -> String? {
        guard
            skyjoPlayerID == playerID,
            let raw = entries[playerID],
            let minOther = minOtherScore(excluding: playerID),
            raw >= minOther,
            raw > 0
        else { return nil }
        return "×2 → \(raw * 2)"
    }
}

// MARK: - Score input row

private struct ScoreInputRow: View {
    let player: Player
    let colorIndex: Int
    let digits: String
    let isNegative: Bool
    let doublingPreview: String?
    let isFocused: Bool
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var highContrast: Bool { colorSchemeContrast == .increased }

    private var activeBrand: Color {
        highContrast ? Theme.brandHighContrast : Theme.brand
    }

    private var scoreColor: Color {
        guard !digits.isEmpty else { return Color(.tertiaryLabel) }
        return isNegative ? Color(.systemRed) : Color.primary
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.playerColor(at: colorIndex, highContrast: highContrast))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(String(player.trimmedName.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.playerTextColor(at: colorIndex, highContrast: highContrast))
                }
                .accessibilityHidden(true)

            Text(player.trimmedName)
                .font(.system(.body, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityHidden(true)

            if let preview = doublingPreview {
                Text(preview)
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(Color(.systemOrange))
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
                    .accessibilityHidden(true)
            }

            HStack(spacing: 1) {
                Text("\u{2212}")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color(.systemRed))
                    .opacity(isNegative ? 1 : 0)
                    .accessibilityHidden(true)

                Text(digits.isEmpty ? "0" : digits)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(scoreColor)
                    .frame(width: 52, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 64)
        .contentShape(Rectangle())
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(activeBrand, lineWidth: 2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
            }
        }
        .onTapGesture { onTap() }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: doublingPreview)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.1), value: isFocused)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Tap to enter score")
    }

    private var rowAccessibilityLabel: String {
        var parts: [String] = [player.trimmedName]
        if digits.isEmpty {
            parts.append("no score")
        } else {
            let sign = isNegative ? "minus " : ""
            parts.append("\(sign)\(digits) points")
        }
        if let preview = doublingPreview,
           let doubled = preview.components(separatedBy: "→").last?.trimmingCharacters(in: .whitespaces) {
            parts.append("doubles to \(doubled)")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Skyjo chip

private struct SkyjoChip: View {
    var player: Player? = nil
    var label: String? = nil
    var colorIndex: Int = 0
    var isNobody: Bool = false
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var highContrast: Bool { colorSchemeContrast == .increased }

    private var displayLabel: String {
        if let player { return player.trimmedName }
        return label ?? ""
    }

    private var chipAccessibilityLabel: String {
        isNobody ? String(localized: "Nobody called Skyjo") : String(localized: "\(displayLabel) called Skyjo")
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if !isNobody, let player {
                    Circle()
                        .fill(isSelected ? Theme.playerColor(at: colorIndex, highContrast: highContrast) : Color(.tertiarySystemFill))
                        .frame(width: 22, height: 22)
                        .overlay {
                            Text(String(player.trimmedName.prefix(1)).uppercased())
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    isSelected
                                        ? Theme.playerTextColor(at: colorIndex, highContrast: highContrast)
                                        : Color(.secondaryLabel)
                                )
                        }
                        .accessibilityHidden(true)
                }
                Text(displayLabel)
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(isSelected ? (isNobody ? activeBrand : Theme.playerColor(at: colorIndex, highContrast: highContrast)) : Color(.label))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected
                          ? (isNobody ? activeBrand.opacity(0.1) : Theme.playerColor(at: colorIndex, highContrast: highContrast).opacity(0.1))
                          : Color(.secondarySystemFill))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isSelected ? (isNobody ? activeBrand : Theme.playerColor(at: colorIndex, highContrast: highContrast)) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.12), value: isSelected)
        .accessibilityLabel(chipAccessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var activeBrand: Color {
        highContrast ? Theme.brandHighContrast : Theme.brand
    }
}
