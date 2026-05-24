import Foundation

/// Persists the active game session to the app's Application Support directory.
/// All operations are silent — no errors are surfaced to the caller or the user.
struct SessionStore {

    /// The file URL for the saved game state.
    /// Internal (not private) so tests can write corrupt data directly.
    static var fileURL: URL? {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("active-game.json")
    }

    /// Encodes and writes the snapshot atomically. Silent on any failure.
    static func save(_ snapshot: GameSessionSnapshot) {
        guard let url = fileURL else { return }
        do {
            let data = try JSONEncoder().encode(snapshot)
            let dir = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: dir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            try data.write(to: url, options: .atomic)
        } catch {
            // Silent per FR-06
        }
    }

    /// Decodes and returns the saved snapshot, or nil if absent or undecodable.
    static func load() -> GameSessionSnapshot? {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(GameSessionSnapshot.self, from: data)
    }

    /// Deletes the saved snapshot. Silent on any failure.
    static func clear() {
        guard let url = fileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
