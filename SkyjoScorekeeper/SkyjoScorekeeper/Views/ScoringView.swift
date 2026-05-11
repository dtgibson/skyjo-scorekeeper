import SwiftUI

struct ScoringView: View {
    @StateObject private var session: GameSession
    let onNewGame: ([Player]?) -> Void

    @State private var showEntrySheet = false
    @State private var showWinView = false

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
                }
                enterButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
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
    }

    // MARK: - Nav bar

    private var navBar: some View {
        HStack {
            Color.clear.frame(width: 70)
            Text("Round \(session.currentRoundNumber)")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
            Button {
                session.undoLastRound()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                    Text("Undo")
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(session.rounds.isEmpty ? Color(.tertiaryLabel) : Theme.brand)
            }
            .disabled(session.rounds.isEmpty)
            .frame(width: 70, alignment: .trailing)
        }
        .frame(height: 52)
        .padding(.horizontal, 20)
    }

    // MARK: - Standings

    private var standingsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("STANDINGS")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)

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
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 58)
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

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.playerColor(at: colorIndex))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(String(standing.player.trimmedName.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.playerTextColor(at: colorIndex))
                }

            Text(standing.player.trimmedName)
                .font(.system(size: 17, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)

            if showLeaderIndicator {
                Circle()
                    .fill(standing.isLeader ? Color(.systemGreen) : Color.clear)
                    .frame(width: 8, height: 8)
            }

            Text("\(standing.total)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(standing.total >= 100 ? Color(.systemRed) : Color.primary)
        }
        .padding(.horizontal, 16)
        .frame(height: 62)
        .background(
            showLeaderIndicator && standing.isLeader
                ? Color(.systemGreen).opacity(0.07)
                : Color.clear
        )
        .animation(.easeInOut(duration: 0.15), value: standing.isLeader)
    }
}
