import Foundation

/// A lightweight Codable snapshot of a GameSession.
/// Used exclusively for persistence — written to disk after each
/// committed action and read on launch to restore an in-progress game.
struct GameSessionSnapshot: Codable {
    let players: [Player]
    let rounds: [Round]
}
