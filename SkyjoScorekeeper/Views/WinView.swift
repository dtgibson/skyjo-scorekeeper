import SwiftUI

struct WinView: View {
    let session: GameSession
    let onNewGame: ([Player]?) -> Void

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                heroSection
                    .padding(.bottom, 24)

                ScrollView {
                    rankingsCard
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .frame(maxWidth: Theme.contentMaxWidth)
                        .frame(maxWidth: .infinity)
                }

                actionButtons
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .frame(maxWidth: Theme.contentMaxWidth)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 52)

            Text(winnerEmoji)
                .font(.system(size: 64))

            Text(winnerHeadline)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.brand)
                .multilineTextAlignment(.center)
                .tracking(-0.5)

            Text(winnerSubtitle)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .frame(maxWidth: Theme.contentMaxWidth)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Theme.brand.opacity(0.07), Color(.systemGroupedBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Rankings

    private var rankingsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FINAL STANDINGS")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .padding(.horizontal, 6)

            let standings = session.standings
            VStack(spacing: 0) {
                ForEach(Array(standings.enumerated()), id: \.element.player.id) { index, standing in
                    FinalRankRow(
                        standing: standing,
                        rank: index + 1,
                        colorIndex: colorIndex(for: standing.player),
                        isWinner: session.winners.contains(where: { $0.id == standing.player.id })
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

    // MARK: - Action buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                onNewGame(session.players)
            } label: {
                Label("New Game — Same Players", systemImage: "arrow.clockwise")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: true))

            Button {
                onNewGame(nil)
            } label: {
                Text("Start Fresh")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.brand)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Computed strings

    private var winnerEmoji: String {
        let winners = session.winners
        if winners.isEmpty { return "🏆" }
        return winners.count > 1 ? "🤝" : "🏆"
    }

    private var winnerHeadline: String {
        let winners = session.winners
        if winners.isEmpty { return "Game Over" }
        if winners.count == 1 { return "\(winners[0].trimmedName) Wins!" }
        let names = winners.map(\.trimmedName)
        let joined = names.dropLast().joined(separator: ", ") + " & " + (names.last ?? "")
        return "\(joined) Tie!"
    }

    private var winnerSubtitle: String {
        let rounds = session.rounds.count
        return "\(rounds) round\(rounds == 1 ? "" : "s") played"
    }

    private func colorIndex(for player: Player) -> Int {
        session.players.firstIndex(where: { $0.id == player.id }) ?? 0
    }
}

// MARK: - Final rank row

private struct FinalRankRow: View {
    let standing: PlayerStanding
    let rank: Int
    let colorIndex: Int
    let isWinner: Bool

    private var medalEmoji: String? {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return nil
        }
    }

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

            if let medal = medalEmoji {
                Text(medal)
                    .font(.system(size: 18))
            }

            Text("\(standing.total)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(standing.total >= 100 ? Color(.systemRed) : Color.primary)
        }
        .padding(.horizontal, 16)
        .frame(height: 62)
        .background(isWinner ? Theme.brand.opacity(0.18) : Color.clear)
    }
}
