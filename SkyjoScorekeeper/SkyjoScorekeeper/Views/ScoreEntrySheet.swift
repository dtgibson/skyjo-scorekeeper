import SwiftUI

struct ScoreEntrySheet: View {
    @ObservedObject var session: GameSession
    let onCommit: ([UUID: Int], UUID?) -> Void

    @State private var rawInputs: [UUID: String] = [:]
    @State private var skyjoPlayerID: UUID? = nil
    @State private var skyjoAnswered = false

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

    private var minRawScore: Int? {
        guard allFilled else { return nil }
        return entries.values.min()
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
            }

            confirmButton
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Handle

    private var handle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color(.tertiaryLabel))
            .frame(width: 36, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }

    // MARK: - Scores

    private var scoresSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ROUND \(session.currentRoundNumber) SCORES")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)

            VStack(spacing: 0) {
                ForEach(Array(session.players.enumerated()), id: \.element.id) { index, player in
                    ScoreInputRow(
                        player: player,
                        colorIndex: index,
                        rawInput: inputBinding(for: player.id),
                        doublingPreview: doublingPreview(for: player.id)
                    )
                    if index < session.players.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        }
    }

    // MARK: - Skyjo question

    private var skyjoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DID ANYONE SKYJO?")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)

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
                            }
                        )
                    }
                    SkyjoChip(
                        label: "Nobody",
                        isNobody: true,
                        isSelected: skyjoAnswered && skyjoPlayerID == nil,
                        onTap: {
                            skyjoPlayerID = nil
                            skyjoAnswered = true
                        }
                    )
                }
            }
            .padding(12)
            .background(.white)
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
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 58)
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
            let min = minRawScore,
            raw > min
        else { return nil }
        return "×2 → \(raw * 2)"
    }
}

// MARK: - Score input row

private struct ScoreInputRow: View {
    let player: Player
    let colorIndex: Int
    @Binding var rawInput: String
    let doublingPreview: String?

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.playerColor(at: colorIndex))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(String(player.trimmedName.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.playerTextColor(at: colorIndex))
                }

            Text(player.trimmedName)
                .font(.system(size: 17, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            if let preview = doublingPreview {
                Text(preview)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.systemOrange))
                    .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }

            TextField("0", text: $rawInput)
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .frame(width: 60)
        }
        .padding(.horizontal, 16)
        .frame(height: 62)
        .animation(.easeInOut(duration: 0.15), value: doublingPreview)
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

    private var displayLabel: String {
        if let player { return player.trimmedName }
        return label ?? ""
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if !isNobody, let player {
                    Circle()
                        .fill(isSelected ? Theme.playerColor(at: colorIndex) : Color(.tertiarySystemFill))
                        .frame(width: 22, height: 22)
                        .overlay {
                            Text(String(player.trimmedName.prefix(1)).uppercased())
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(isSelected ? Theme.playerTextColor(at: colorIndex) : Color(.secondaryLabel))
                        }
                }
                Text(displayLabel)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? (isNobody ? Theme.brand : Theme.playerColor(at: colorIndex)) : Color(.label))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected
                          ? (isNobody ? Theme.brand.opacity(0.1) : Theme.playerColor(at: colorIndex).opacity(0.1))
                          : Color(.secondarySystemFill))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isSelected ? (isNobody ? Theme.brand : Theme.playerColor(at: colorIndex)) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }
}
