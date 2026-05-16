import SwiftUI

struct ScoreEntrySheet: View {
    @ObservedObject var session: GameSession
    let onCommit: ([UUID: Int], UUID?) -> Void

    @State private var rawInputs: [UUID: String] = [:]
    @State private var skyjoPlayerID: UUID? = nil
    @State private var skyjoAnswered = false
    @FocusState private var focusedPlayer: UUID?

    private var entries: [UUID: Int] {
        Dictionary(uniqueKeysWithValues: session.players.compactMap { player in
            guard let text = rawInputs[player.id], let value = Int(text) else { return nil }
            return (player.id, value)
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
                .padding(.bottom, 24)
                .frame(maxWidth: Theme.contentMaxWidth)
                .frame(maxWidth: .infinity)
            }

            confirmButton
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .frame(maxWidth: Theme.contentMaxWidth)
                .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Next") { advanceFocus() }
                    .disabled(focusedPlayer == session.players.last?.id)
                Button("Done") { focusedPlayer = nil }
            }
        }
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
                        rawInput: inputBinding(for: player.id),
                        doublingPreview: doublingPreview(for: player.id),
                        focusedPlayer: $focusedPlayer
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

            VStack(spacing: 8) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(Array(session.players.enumerated()), id: \.element.id) { index, player in
                        SkyjoChip(
                            player: player,
                            colorIndex: index,
                            isSelected: skyjoPlayerID == player.id,
                            onTap: {
                                skyjoPlayerID = player.id
                                skyjoAnswered = true
                                focusedPlayer = nil
                            }
                        )
                    }
                    SkyjoChip(
                        label: "Skip",
                        isNobody: true,
                        isSelected: skyjoAnswered && skyjoPlayerID == nil,
                        onTap: {
                            skyjoPlayerID = nil
                            skyjoAnswered = true
                            focusedPlayer = nil
                        }
                    )
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
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

    private func inputBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { rawInputs[id] ?? "" },
            set: { rawInputs[id] = $0 }
        )
    }

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

    private func advanceFocus() {
        guard let current = focusedPlayer,
              let idx = session.players.firstIndex(where: { $0.id == current }),
              idx + 1 < session.players.count
        else { return }
        focusedPlayer = session.players[idx + 1].id
    }
}

// MARK: - Score input row

private struct ScoreInputRow: View {
    let player: Player
    let colorIndex: Int
    @Binding var rawInput: String
    let doublingPreview: String?
    var focusedPlayer: FocusState<UUID?>.Binding

    @State private var digits: String = ""
    @State private var isNegative: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var highContrast: Bool { colorSchemeContrast == .increased }

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
                    .accessibilityLabel(doublingAccessibilityLabel(preview))
            }

            Button {
                isNegative.toggle()
                syncToBinding()
            } label: {
                Image(systemName: isNegative ? "minus.circle.fill" : "minus.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isNegative ? Color(.systemRed) : Color(.tertiaryLabel))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Negative score")
            .accessibilityValue(isNegative ? "on" : "off")

            TextField("0", text: $digits)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .frame(width: 52)
                .focused(focusedPlayer, equals: player.id)
                .onChange(of: digits) { _, _ in syncToBinding() }
                .accessibilityLabel("Score for \(player.trimmedName)")
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 64)
        .contentShape(Rectangle())
        .onTapGesture { focusedPlayer.wrappedValue = player.id }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: doublingPreview)
    }

    private func syncToBinding() {
        guard !digits.isEmpty else { rawInput = ""; return }
        rawInput = isNegative ? "-\(digits)" : digits
    }

    private func doublingAccessibilityLabel(_ preview: String) -> String {
        if let doubled = preview.components(separatedBy: "→").last?.trimmingCharacters(in: .whitespaces) {
            return "Score doubles to \(doubled)"
        }
        return preview
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
        isNobody ? "Nobody called Skyjo" : "\(displayLabel) called Skyjo"
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
