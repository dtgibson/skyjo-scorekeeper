import SwiftUI

struct ScoringView: View {
    @StateObject private var session: GameSession
    let onNewGame: ([Player]?) -> Void

    @State private var showEntrySheet = false
    @State private var showWinView = false
    @State private var showEndGameAlert = false

    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var activeBrand: Color {
        colorSchemeContrast == .increased ? Theme.brandHighContrast : Theme.brand
    }

    init(players: [Player], onNewGame: @escaping ([Player]?) -> Void) {
        _session = StateObject(wrappedValue: GameSession(players: players))
        self.onNewGame = onNewGame
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                ScrollView {
                    standingsCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                        .frame(maxWidth: Theme.contentMaxWidth)
                        .frame(maxWidth: .infinity)
                }
                enterButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .frame(maxWidth: Theme.contentMaxWidth)
                    .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showEntrySheet) {
            ScoreEntrySheet(session: session) { entries, skyjoPlayerID in
                session.commitRound(entries: entries, skyjoPlayerID: skyjoPlayerID)
                showEntrySheet = false
                if session.isGameOver {
                    showWinView = true
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(isPresented: $showWinView) {
            WinView(session: session, onNewGame: onNewGame)
        }
        .alert("End Game?", isPresented: $showEndGameAlert) {
            Button("End Game", role: .destructive) { onNewGame(nil) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current scores will be lost.")
        }
    }

    // MARK: - Nav bar

    private var navBar: some View {
        HStack {
            Button {
                showEndGameAlert = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                    Text("End Game")
                }
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(activeBrand)
            }
            .frame(width: 80, alignment: .leading)

            Text("Round \(session.currentRoundNumber)")
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity)

            Button {
                session.undoLastRound()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                    Text("Undo")
                }
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(session.rounds.isEmpty ? Color(.tertiaryLabel) : activeBrand)
            }
            .disabled(session.rounds.isEmpty)
            .accessibilityHint("Removes the most recent round's scores")
            .frame(width: 80, alignment: .trailing)
        }
        .frame(minHeight: 52)
        .padding(.horizontal, 20)
        .frame(maxWidth: Theme.contentMaxWidth)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Standings

    private var standingsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STANDINGS")
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)
                .accessibilityAddTraits(.isHeader)

            let standings = session.standings
            VStack(spacing: 0) {
                ForEach(Array(standings.enumerated()), id: \.element.player.id) { index, standing in
                    StandingRowView(
                        standing: standing,
                        colorIndex: colorIndex(for: standing.player),
                        showLeaderIndicator: !session.rounds.isEmpty
                    )
                    if index < standings.count - 1 {
                        Divider().padding(.leading, 64)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
        }
    }

    // MARK: - Enter button

    private var enterButton: some View {
        Button { showEntrySheet = true } label: {
            Label("Enter Round \(session.currentRoundNumber) Scores", systemImage: "chevron.up")
                .font(.system(.headline, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 58)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: true))
    }

    private func colorIndex(for player: Player) -> Int {
        session.players.firstIndex(where: { $0.id == player.id }) ?? 0
    }
}

// MARK: - Standing row

private struct StandingRowView: View {
    let standing: PlayerStanding
    let colorIndex: Int
    let showLeaderIndicator: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private var highContrast: Bool { colorSchemeContrast == .increased }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.playerColor(at: colorIndex, highContrast: highContrast))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(String(standing.player.trimmedName.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.playerTextColor(at: colorIndex, highContrast: highContrast))
                }

            Text(standing.player.trimmedName)
                .font(.system(.body, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            if showLeaderIndicator {
                Image(systemName: "crown.fill")
                    .font(.system(.caption2))
                    .foregroundStyle(Color(.systemGreen))
                    .opacity(standing.isLeader ? 1 : 0)
                    .accessibilityHidden(true)
            }

            Text("\(standing.total)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(standing.total >= 100 ? Color(.systemRed) : Color.primary)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 62)
        .background(
            showLeaderIndicator && standing.isLeader
                ? Color(.systemGreen).opacity(0.07)
                : Color.clear
        )
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: standing.isLeader)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
    }

    private var rowAccessibilityLabel: String {
        let name = standing.player.trimmedName
        let points = "\(standing.total) points"
        let leader = standing.isLeader && showLeaderIndicator ? ", currently leading" : ""
        return "\(name), \(points)\(leader)"
    }
}
