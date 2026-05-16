# Schema — Game Setup

## Path
Frontend Only — No data layer changes required

## Confirmation
Every requirement in the PRD has been checked. All functional requirements involve UI behavior, in-session state, or input validation. No records are created, read from a database, updated, or deleted. No migrations are needed.

## Existing Data Used by This Feature
None. This is the first feature in a brand new project. There is no prior schema and no persistent data store.

## In-Memory Models (SwiftUI State)

The Engineer will need to introduce the following Swift value types to support this feature. These are not database models — they are in-memory structs that live for the duration of a session.

### Player
- `id: UUID` — stable identity for SwiftUI list operations
- `name: String` — the player's display name (trimmed before use)

### GameSetup
- `players: [Player]` — ordered list of players for the current game (min 2, max 8)
- Passed to the active game screen when the game starts
- Passed back to the setup screen when "New Game" is tapped post-win

## No Data Layer Work Required
The Engineer can proceed directly to UI implementation. No migrations need to be written or run for this feature.
