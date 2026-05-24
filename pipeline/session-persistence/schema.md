# Schema — Session Persistence

**Feature:** session-persistence
**Date:** 2026-05-24
**Stage:** 3 — The Architect
**Path:** Incremental (extending existing schema)

---

## Current Schema State

Complete model state after this feature's changes are applied.

### `Player` — extended
```swift
struct Player: Identifiable, Equatable, Codable {
    var id: UUID
    var name: String
    var trimmedName: String { ... }  // computed, not encoded
    var isValid: Bool { ... }        // computed, not encoded
}
```

### `RoundScore` — extended
```swift
struct RoundScore: Codable {
    let playerID: UUID
    let raw: Int
    let applied: Int
}
```

### `Round` — extended
```swift
struct Round: Codable {
    let number: Int
    let scores: [RoundScore]
    let skyjoPlayerID: UUID?
}
```

### `PlayerStanding` — unchanged
```swift
struct PlayerStanding {
    let player: Player
    let total: Int
    let isLeader: Bool
    let lastRoundScore: Int?
}
```
Computed on demand from `GameSession.rounds`. Never stored.

### `GameSessionSnapshot` — new
```swift
struct GameSessionSnapshot: Codable {
    let players: [Player]
    let rounds: [Round]
}
```
A pure Codable value snapshot of `GameSession` state. Written to disk on every committed change; read on launch to restore a game in progress.

### `SessionStore` — new
```swift
struct SessionStore {
    static func save(_ snapshot: GameSessionSnapshot)
    static func load() -> GameSessionSnapshot?
    static func clear()
}
```
Pure static service. All three operations are silent — no throws, no user-visible errors.

- **Storage location:** `FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first! / "active-game.json"`
- `save` encodes with `JSONEncoder` and writes atomically; swallows any encoding or I/O error
- `load` decodes with `JSONDecoder`; returns `nil` on any failure (missing file, corrupt data, schema mismatch)
- `clear` deletes the file; swallows any error

### `GameSession` — extended
```swift
final class GameSession: ObservableObject {
    let players: [Player]
    @Published var rounds: [Round]

    // Existing
    var currentRoundNumber: Int
    var standings: [PlayerStanding]
    var isGameOver: Bool
    var winners: [Player]
    func commitRound(entries:skyjoPlayerID:)
    func undoLastRound()

    // Added
    init(snapshot: GameSessionSnapshot)         // restore path — does NOT clear store
    var snapshot: GameSessionSnapshot { get }   // current state as Codable value
}
```

Save/clear triggers within `GameSession`:
- `commitRound` → `SessionStore.save(snapshot)` after appending the round
- `undoLastRound` → `SessionStore.save(snapshot)` after removing the round
- `init(players:)` (fresh game) → `SessionStore.clear()` on init

### `SkyjoScorekeeperApp` — extended

Launch routing:
```
if let snapshot = SessionStore.load() {
    route = .game(session: GameSession(snapshot: snapshot))
} else {
    route = .setup
}
```

`onNewGame` callback (called from End Game, Start Fresh, New Game Same Players):
```
SessionStore.clear()
route = .setup(initialPlayers: players)
```

The `Route` enum gains a `.game(session: GameSession)` case alongside or replacing `.game(players: [Player])`, so a pre-built `GameSession` can be injected directly on restore.

---

## Changes in This Feature

### Added
- `Codable` conformance on `Player`, `RoundScore`, `Round` — synthesized automatically, no manual implementation
- `GameSessionSnapshot` struct — new file `SkyjoScorekeeper/Models/GameSessionSnapshot.swift`
- `SessionStore` struct — new file `SkyjoScorekeeper/Models/SessionStore.swift`
- `GameSession.init(snapshot:)` — restore initializer
- `GameSession.snapshot` — computed property returning current state as `GameSessionSnapshot`
- Save call in `GameSession.commitRound`
- Save call in `GameSession.undoLastRound`
- Clear call in `GameSession.init(players:)`
- Clear call in `SkyjoScorekeeperApp.onNewGame`
- Restore logic in `SkyjoScorekeeperApp` init / body

### Modified
- `Player.swift` — add `Codable` to protocol list
- `RoundScore.swift` — add `Codable` to protocol list
- `Round.swift` — add `Codable` to protocol list
- `GameSession.swift` — add snapshot property, restore init, save/clear call sites
- `SkyjoScorekeeperApp.swift` — launch routing, onNewGame clear

### Unchanged
- `PlayerStanding` — computed, never persisted
- `GameState` — setup screen model, unrelated to persistence
- All views — no view changes required for this feature
- `Theme.swift` — unchanged
- All test files — new unit tests added but existing tests unmodified

---

## Migration Plan

No database migrations. Steps for the Engineer:

1. Add `Codable` to `Player`, `RoundScore`, `Round` protocol lists
2. Create `SkyjoScorekeeper/Models/GameSessionSnapshot.swift`
3. Create `SkyjoScorekeeper/Models/SessionStore.swift`
4. Update `GameSession.swift`:
   - Add `var snapshot: GameSessionSnapshot` computed property
   - Add `init(snapshot: GameSessionSnapshot)`
   - Add `SessionStore.save(snapshot)` at end of `commitRound`
   - Add `SessionStore.save(snapshot)` at end of `undoLastRound`
   - Add `SessionStore.clear()` at start of `init(players:)`
5. Update `SkyjoScorekeeperApp.swift`:
   - On launch, call `SessionStore.load()`; if non-nil, init `GameSession(snapshot:)` and route to game
   - In `onNewGame`, call `SessionStore.clear()` before switching route

---

## Design Decisions

- **`GameSessionSnapshot` separate from `GameSession`**: `GameSession` is an `ObservableObject` class with `@Published` properties. Making it directly `Codable` is possible but fragile — `@Published` wrappers interfere with synthesis and the class would need manual `encode`/`init(from:)`. A separate value-type snapshot is cleaner and keeps persistence concerns out of the model.

- **`SessionStore` as a static struct**: No state to hold, no injection needed. A static struct keeps the API minimal and testable without requiring dependency injection across the call stack.

- **Application Support, not Documents**: `active-game.json` is app-managed state, not a user-accessible document. Application Support is the correct sandbox location. iTunes/Finder file sharing will not expose it.

- **Silent failures everywhere**: Per FR-06 and FR-11, all persistence failures are swallowed. A save failure means the next restore might be stale or absent — acceptable. A load failure means a fresh start — also acceptable. Showing an error for either would be worse than silently handling it.

- **Clear on `init(players:)` AND in `onNewGame`**: Belt-and-suspenders. `onNewGame` covers all user-initiated game endings before a new session starts; `init(players:)` covers any future path that creates a fresh `GameSession` directly without going through the app's routing callback.
