# Schema — Score Tracking

**Feature:** score-tracking
**Date:** 2026-05-09
**Stage:** 3 — The Architect
**Path:** Incremental — extends existing `Player` model

---

## Existing Models (from Game Setup)

```swift
struct Player: Identifiable, Equatable {
    var id: UUID
    var name: String
    var trimmedName: String { ... }
    var isValid: Bool { ... }
}
```

`Player` is passed into the score tracking screen as a confirmed, immutable list. This feature does not modify `Player`.

---

## New Models Required

### `RoundScore`

One player's score in a single round.

```swift
struct RoundScore {
    let playerID: UUID
    let raw: Int        // score as entered
    let applied: Int    // after doubling rule (may equal raw)
}
```

### `Round`

One completed round.

```swift
struct Round {
    let number: Int
    let scores: [RoundScore]
    let skyjoPlayerID: UUID?   // nil if no one Skyjo'd
}
```

### `PlayerStanding`

Computed view of one player's state. Derived on demand, never stored.

```swift
struct PlayerStanding {
    let player: Player
    let total: Int
    let isLeader: Bool
    let lastRoundScore: Int?
}
```

### `GameSession` (ObservableObject)

Central state object for the active game.

```swift
final class GameSession: ObservableObject {
    let players: [Player]
    @Published var rounds: [Round]

    var currentRoundNumber: Int      // rounds.count + 1
    var standings: [PlayerStanding]  // sorted ascending by total
    var isGameOver: Bool             // any total >= 100
    var winners: [Player]            // lowest total; tiebreaker = last round score
}
```

---

## Doubling Rule Logic

Applied during confirmation, before appending to `rounds`:

```
if skyjoPlayerID != nil:
    if skyjoRawScore > min(all rawScores):
        applied = raw * 2
    else:
        applied = raw   // no doubling
```

---

## Undo Logic

Remove `rounds.last`. All computed properties (standings, isGameOver, winners) derive from `rounds`, so undo is automatic.

---

## Navigation Model

Root-level enum managed in the App or root view:

```swift
enum AppScreen {
    case setup(initialPlayers: [Player]? = nil)
    case game(players: [Player])
}
```

- Game Setup → Start Game → `.game(players:)`
- Scoring → New Game → `.setup(initialPlayers:)`

---

## No Data Layer Changes

All state is in-memory. No persistence, no migrations.
