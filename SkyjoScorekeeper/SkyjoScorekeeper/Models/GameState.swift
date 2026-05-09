import Foundation
import Combine

final class GameState: ObservableObject {
    static let minPlayers = 2
    static let maxPlayers = 8

    @Published var players: [Player]

    init(players: [Player] = [Player(), Player()]) {
        self.players = players
    }

    var canStart: Bool {
        validPlayers.count >= GameState.minPlayers
    }

    var validPlayers: [Player] {
        players.filter { $0.isValid }
    }

    var canAddPlayer: Bool {
        players.count < GameState.maxPlayers
    }

    var canRemovePlayer: Bool {
        players.count > GameState.minPlayers
    }

    func addPlayer() {
        guard canAddPlayer else { return }
        players.append(Player())
    }

    func remove(_ player: Player) {
        guard canRemovePlayer else { return }
        players.removeAll { $0.id == player.id }
    }

    // Returns trimmed, validated players ready to start a game.
    // Returns nil if fewer than minPlayers valid names exist.
    func committedPlayers() -> [Player]? {
        guard canStart else { return nil }
        return players.map { Player(id: $0.id, name: $0.trimmedName) }
    }
}
