# Schema — Localization

## Path
Frontend Only — No data layer changes required

## Confirmation
All 12 functional requirements were reviewed against the data layer checklist. Every requirement describes either: adding string entries to a `Localizable.xcstrings` resource file, wrapping Swift computed strings in `String(localized:)`, configuring CLDR plural rules in the catalog, adding translator comments, or validating RTL layout rendering. No new records are created, read in a new way, updated, or deleted. No new relationships or derived stored data are introduced.

## Existing Data Used by This Feature

### Player
- **Fields used:** `id: UUID`, `name: String` (accessed via `trimmedName`)
- **How used:** `trimmedName` is interpolated into every player-specific localized format string — "Score for %@", "Remove %@", "%@ name", "%@ name, required", "%@ called Skyjo", "%@ Wins!", "%@ Tie!", "%1$@: %2$@, %3$lld points". Per FR-04, player names are never translated — they pass through as-is.

### GameSession
- **Fields used:** `currentRoundNumber: Int`, `players: [Player]`, `winners: [Player]`
- **How used:** `currentRoundNumber` is interpolated into "Round %lld", "Enter Round %lld Scores", "ROUND %lld SCORES", "Confirm Round %lld". `players` drives the score entry rows and Skyjo chip labels. `winners` supplies the name(s) for "%@ Wins!" / "%@ Tie!" on the win screen.

### PlayerStanding
- **Fields used:** `player: Player`, `total: Int`, `isLeader: Bool`, computed placement (first/second/third/other)
- **How used:** `total` appears in the combined accessibility row label "%1$@: %2$@, %3$lld points". `isLeader` determines whether ", currently leading" is appended to the label. Placement drives "First place" / "Second place" / "Third place" / "Place %lld".

### Round
- **Fields used:** `rounds.count: Int`
- **How used:** Round count drives the "%lld rounds played" plural string on the win screen. This is the only string in the app requiring CLDR plural rules (FR-06) — English needs `one`/`other`; other languages need additional categories (zero, two, few, many) as applicable.

## No Data Layer Work Required
The Engineer can proceed directly to resource file creation and Swift string wrapping. No migrations need to be written or run for this feature.
