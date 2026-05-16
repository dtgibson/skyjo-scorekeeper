# Schema — Accessibility

## Path
Frontend Only — No data layer changes required

## Confirmation
Every functional requirement in the PRD has been reviewed. All requirements describe accessibility modifier additions, Dynamic Type font style changes, color variants in Theme.swift, Reduce Motion environment checks, and a non-color visual indicator added to StandingRowView. No new tables, columns, relationships, or migrations are needed.

## Existing Data Used by This Feature

### Player
- Fields used: `id: UUID`, `name: String`
- How used: `name` is the primary input for all VoiceOver labels — "Remove Alice", "Score for Alice", "Alice called Skyjo", "First place: Alice, 45 points"

### PlayerStanding
- Fields used: `player: Player`, `total: Int`, `isLeader: Bool`
- How used: Combined into a single VoiceOver label per standing row — "[name], [total] points, currently leading" or "[name], [total] points". `isLeader` also drives the non-color leader symbol (FR-34).

### GameSession
- Fields used: `players: [Player]`, `currentRoundNumber: Int`, `standings: [PlayerStanding]`, `winners: [Player]`, `rounds: [Round]`
- How used: `currentRoundNumber` appears in section headings and button labels that require accessibility context. `winners` used to build the VoiceOver label for WinView rows (winner status). `rounds.isEmpty` determines the Undo button's disabled state for VoiceOver announcement.

### Round / RoundScore
- Fields used: none directly referenced in UI accessibility labels
- How used: Not directly used by any accessibility requirement — game logic remains untouched.

## No Data Layer Work Required
The Engineer can proceed directly to UI implementation. No migrations need to be written or run for this feature.
