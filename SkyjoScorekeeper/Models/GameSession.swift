import Foundation
import Combine

final class GameSession: ObservableObject {
    /// A player's total reaching this score ends the game.
    static let bustThreshold = 100
    /// Totals at or above this (but below `bustThreshold`) are in the danger zone.
    static let dangerThreshold = 85

    /// How close a player's total is to busting — drives the scoreboard cues.
    enum ScoreStatus: Equatable {
        case normal, approaching, bust
    }

    static func scoreStatus(for total: Int) -> ScoreStatus {
        if total >= bustThreshold { return .bust }
        if total >= dangerThreshold { return .approaching }
        return .normal
    }

    let players: [Player]
    @Published private(set) var rounds: [Round] = []

    /// Start a fresh game. Clears any previously saved state.
    init(players: [Player]) {
        SessionStore.clear()
        self.players = players
    }

    /// Restore a game from a persisted snapshot. Does NOT clear saved state.
    init(snapshot: GameSessionSnapshot) {
        self.players = snapshot.players
        self._rounds = Published(initialValue: snapshot.rounds)
    }

    /// The current state as a Codable value suitable for persistence.
    var snapshot: GameSessionSnapshot {
        GameSessionSnapshot(players: players, rounds: rounds)
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

    var isGameOver: Bool { standings.contains { $0.total >= Self.bustThreshold } }

    var winners: [Player] {
        guard isGameOver, let minimum = standings.first?.total else { return [] }
        let tied = standings.filter { $0.total == minimum }
        if tied.count == 1 { return tied.map(\.player) }
        let minLast = tied.compactMap(\.lastRoundScore).min()
        return tied.filter { $0.lastRoundScore == minLast }.map(\.player)
    }

    /// True when two or more players tied on the lowest total and the
    /// final-round tiebreaker produced a single winner.
    var wasTieBroken: Bool {
        guard isGameOver, let minimum = standings.first?.total else { return false }
        let tiedOnTotal = standings.filter { $0.total == minimum }.count
        return tiedOnTotal > 1 && winners.count == 1
    }

    /// The doubling rule, in one place: a round-ender's positive score
    /// doubles unless it is strictly lower than every other score.
    /// Used by both `commitRound` and the live entry preview so they
    /// can never disagree.
    static func isDoubled(raw: Int, minOther: Int?) -> Bool {
        raw > 0 && raw >= (minOther ?? Int.min)
    }

    func commitRound(entries: [UUID: Int], skyjoPlayerID: UUID?) {
        let otherMin: Int? = skyjoPlayerID.flatMap { id in
            entries.filter { $0.key != id }.values.min()
        }
        let scores: [RoundScore] = players.map { player in
            let raw = entries[player.id] ?? 0
            let doubled = skyjoPlayerID == player.id
                && Self.isDoubled(raw: raw, minOther: otherMin)
            return RoundScore(playerID: player.id, raw: raw, applied: doubled ? raw * 2 : raw)
        }
        rounds.append(Round(number: currentRoundNumber, scores: scores, skyjoPlayerID: skyjoPlayerID))

        // Clear on game over so a restored session never shows a completed game.
        // Save otherwise so any interruption can be recovered.
        if isGameOver {
            SessionStore.clear()
        } else {
            SessionStore.save(snapshot)
        }
    }

    func undoLastRound() {
        guard !rounds.isEmpty else { return }
        rounds.removeLast()
        SessionStore.save(snapshot)
    }
}
