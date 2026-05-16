# Schema — iPad Layout

## Path
Frontend Only — No data layer changes required

## Confirmation
Every functional requirement in the PRD has been reviewed. All requirements describe layout width constraints and a UI constant (`Theme.contentMaxWidth`). No new tables, columns, relationships, or migrations are needed.

## Existing Data Used by This Feature

### Player
- Fields used: `id: UUID`, `name: String`
- How used: Displayed in player name rows in `GameSetupView` and as avatar initials throughout scoring and win screens

### GameSession
- Fields used: `players: [Player]`, `rounds: [Round]`, `currentRoundNumber: Int`, `standings: [PlayerStanding]`, `isGameOver: Bool`, `winners: [Player]`
- How used: Drives all content in `ScoringView`, `ScoreEntrySheet`, and `WinView` — the Engineer adapts the layout of these views without touching the session logic

### PlayerStanding
- Fields used: `player: Player`, `total: Int`, `isLeader: Bool`, `lastRoundScore: Int?`
- How used: Displayed in the standings card (`ScoringView`) and final rankings (`WinView`)

## No Data Layer Work Required
The Engineer can proceed directly to UI implementation. No migrations need to be written or run for this feature.
