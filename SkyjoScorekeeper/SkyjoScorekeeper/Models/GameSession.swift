import Foundation
import Combine

final class GameSession: ObservableObject {
    let players: [Player]
    @Published private(set) var rounds: [Round] = []

    init(players: [Player]) {
        self.players = players
    }

    var currentRoundNumber: Int { rounds.count + 1 }

    private func total(for playerID: UUID) -> Int {
        rounds.reduce(0) { $0 + ($1.scores.first { $0.playerID == playerID }?.applied ?? 0) }
    }

    var standings: [PlayerStanding] {
        let totals = players.map { (player: $0, total: total(for: $0.id)) }
        let minimum = totals.map(\.total).min() ?? 0
        return totals.map { item in
            PlayerStanding(
                player: item.player,
                total: item.total,
                isLeader: item.total == minimum,
                lastRoundScore: rounds.last?.scores.first { $0.playerID == item.player.id }?.applied
            )
        }.sorted { $0.total < $1.total }
    }

    var isGameOver: Bool { standings.contains { $0.total >= 100 } }

    var winners: [Player] {
        guard isGameOver, let minimum = standings.first?.total else { return [] }
        let tied = standings.filter { $0.total == minimum }
        if tied.count == 1 { return tied.map(\.player) }
        let minLast = tied.compactMap(\.lastRoundScore).min()
        return tied.filter { $0.lastRoundScore == minLast }.map(\.player)
    }

    func commitRound(entries: [UUID: Int], skyjoPlayerID: UUID?) {
        let minRaw = entries.values.min() ?? 0
        let scores: [RoundScore] = players.map { player in
            let raw = entries[player.id] ?? 0
            let doubled = skyjoPlayerID == player.id && raw > minRaw
            return RoundScore(playerID: player.id, raw: raw, applied: doubled ? raw * 2 : raw)
        }
        rounds.append(Round(number: currentRoundNumber, scores: scores, skyjoPlayerID: skyjoPlayerID))
    }

    func undoLastRound() {
        guard !rounds.isEmpty else { return }
        rounds.removeLast()
    }
}
