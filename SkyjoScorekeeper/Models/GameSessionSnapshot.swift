import Foundation

/// A lightweight Codable snapshot of a GameSession.
/// Used exclusively for persistence — written to disk after each
/// committed action and read on launch to restore an in-progress game.
struct GameSessionSnapshot: Codable {
    /// The snapshot format version. Optional so files written before
    /// versioning was introduced (no key) decode as `nil` rather than
    /// failing — a `nil` value means "pre-versioning" (treat as 1).
    let schemaVersion: Int?
    let players: [Player]
    let rounds: [Round]

    /// The version this build writes.
    static let currentVersion = 1

    init(players: [Player], rounds: [Round], schemaVersion: Int? = GameSessionSnapshot.currentVersion) {
        self.players = players
        self.rounds = rounds
        self.schemaVersion = schemaVersion
    }
}
