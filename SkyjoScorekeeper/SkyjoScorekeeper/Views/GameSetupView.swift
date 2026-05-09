import SwiftUI

struct GameSetupView: View {
    @StateObject private var gameState: GameState
    @State private var showEasterEgg = false
    @State private var highlightErrors = false

    // Accepts pre-populated players from the play-again flow (FR-11).
    // Defaults to two empty players on fresh launch.
    init(initialPlayers: [Player]? = nil) {
        _gameState = StateObject(
            wrappedValue: GameState(players: initialPlayers ?? [Player(), Player()])
        )
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    playerSection
                        .padding(.horizontal, 16)
                        .padding(.top, 28)
                        .padding(.bottom, 12)
                }

                startSection
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .overlay {
            if showEasterEgg {
                EasterEggOverlay { showEasterEgg = false }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showEasterEgg)
        .onChange(of: gameState.players) { _, _ in
            highlightErrors = false
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 7) {
            Text("Skyjo Scorekeeper")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.brand)
                .tracking(-1.5)
                .onLongPressGesture(minimumDuration: 3) {
                    showEasterEgg = true
                }

            Text("Who's playing today?")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Player list

    private var playerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PLAYERS")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .tracking(0.6)
                .padding(.horizontal, 6)

            VStack(spacing: 0) {
                ForEach(gameState.players) { player in
                    let index = playerIndex(for: player.id)
                    PlayerRowView(
                        name: nameBinding(for: player.id),
                        placeholder: "Player \(index + 1)",
                        avatarLabel: avatarLabel(for: player),
                        colorIndex: index,
                        isFilled: player.isValid,
                        showError: highlightErrors && !player.isValid,
                        canRemove: gameState.canRemovePlayer,
                        onRemove: { gameState.remove(player) }
                    )
                    if player.id != gameState.players.last?.id {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)

            if gameState.canAddPlayer {
                addPlayerButton
            }
        }
    }

    private var addPlayerButton: some View {
        Button {
            gameState.addPlayer()
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(.systemGreen))
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                Text("Add Player")
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 54)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Start section

    private var startSection: some View {
        VStack(spacing: 11) {
            Button(action: attemptStart) {
                Label("Start Game", systemImage: "play.fill")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: gameState.canStart))
            .disabled(!gameState.canStart)

            Text(statusNote)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(gameState.canStart ? Color(.systemGreen) : Color(.tertiaryLabel))
                .animation(.easeInOut(duration: 0.15), value: gameState.canStart)
        }
    }

    private var statusNote: String {
        if gameState.canStart {
            let count = gameState.players.count
            return "\(count) player\(count == 1 ? "" : "s") ready"
        }
        return "Enter at least 2 names to start"
    }

    private func attemptStart() {
        let hasBlankAmongFilled = gameState.players.contains { !$0.isValid }
            && !gameState.validPlayers.isEmpty

        if hasBlankAmongFilled {
            highlightErrors = true
            return
        }

        // Navigate to the game screen — implemented in a future feature.
        _ = gameState.committedPlayers()
    }

    // MARK: - Helpers

    private func nameBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { gameState.players.first(where: { $0.id == id })?.name ?? "" },
            set: { newValue in
                guard let index = gameState.players.firstIndex(where: { $0.id == id }) else { return }
                gameState.players[index].name = newValue
            }
        )
    }

    private func playerIndex(for id: UUID) -> Int {
        gameState.players.firstIndex(where: { $0.id == id }) ?? 0
    }

    private func avatarLabel(for player: Player) -> String {
        guard !player.trimmedName.isEmpty else {
            return "\(playerIndex(for: player.id) + 1)"
        }
        return String(player.trimmedName.prefix(1)).uppercased()
    }
}

// MARK: - Button style

struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.brand.opacity(isEnabled ? 1.0 : 0.28))
            )
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.985 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
