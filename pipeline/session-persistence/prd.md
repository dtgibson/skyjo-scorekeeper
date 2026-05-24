# PRD — Session Persistence
**Feature:** session-persistence
**Session:** 001
**Date:** 2026-05-24
**Stage:** 2 — The Planner
**Source:** strategic-brief.md (approved)

---

## Feature Overview

Automatic save and restore of the active Skyjo game. The app writes game state to local device storage after each committed action and restores it on next launch, so a group can resume exactly where they left off after any interruption — phone call, OS kill, overnight break.

---

## User Stories

**US-01** — As a player mid-game who receives a phone call, I want my scores to be there when I return to the app, so the session isn't ruined by an interruption outside my control.

**US-02** — As a player who accidentally quits the app, I want to reopen it and pick up exactly where I left off, so I don't have to reconstruct the game from memory.

**US-03** — As a player finishing a game, I want the saved data to be cleared when I explicitly end or start a new game, so the next person who opens the app doesn't see stale state from a previous session.

**US-04** — As any player, I want the save/restore cycle to be invisible, so the app feels like a physical scorepad — it just remembers, without asking me to think about it.

---

## Functional Requirements

### Save Behavior

**FR-01** — The app shall save the active game session to local device storage after each round is successfully committed (after the user taps "Confirm Round N").

**FR-02** — The app shall save the active game session after a round is undone.

**FR-03** — Only committed round data shall be saved. A score entry that is in progress (the entry sheet is open but not yet confirmed) shall not be included in the persisted state.

### Restore Behavior

**FR-04** — On launch, if a valid saved game session exists, the app shall bypass the setup screen and restore directly to the scoring view with all player names and round history intact.

**FR-05** — The restored scoring view shall be visually and functionally identical to a live game at the same point — correct round number, correct standings, Undo enabled if rounds exist.

**FR-06** — If saved state cannot be decoded (corrupt data, schema mismatch from an app update), the app shall silently discard it and launch to the setup screen. No error shall be shown to the user.

### Clear Behavior

**FR-07** — The app shall clear saved game state when the user confirms "End Game" from the scoring view's alert.

**FR-08** — The app shall clear saved game state when a new `GameSession` is initialized — i.e. when the user taps "Start Game" from the setup screen. This covers both "New Game — Same Players" and "Start Fresh" flows as they both pass through setup before starting.

**FR-09** — The app shall clear saved game state when the win screen is dismissed via "New Game — Same Players" or "Start Fresh." Saved state is not needed beyond the win screen; clearing at dismissal ensures the next launch lands on setup, not an already-completed game.

### Invisibility

**FR-10** — No UI element shall indicate that saving or restoring is occurring. No spinner, no banner, no "Game resumed" message. The restore is silent.

**FR-11** — The save operation shall not block or visibly delay any user interaction.

---

## Non-Functional Requirements

**NFR-01 — Compatibility:** Game state shall be encoded using `Codable` and stored as JSON in the app's local sandbox. All `Codable` types shall use optional fields with default values for any property that may be added in future versions, so a state file written by an older version of the app can be decoded by a newer one without crashing.

**NFR-02 — Performance:** Encode and write operations shall complete in the background and take no perceptible time. The expected payload size for a full game (8 players × 20 rounds) is well under 50KB.

**NFR-03 — Privacy:** All state is stored in the app's sandboxed container on-device. No data is written to iCloud, transmitted over the network, or shared with any other app or process.

**NFR-04 — Accessibility:** The restored scoring view requires no additional accessibility considerations beyond what already exists. VoiceOver users experience a restored game identically to a live game.

---

## Out of Scope

- Completed game history (persisting sessions after the game ends)
- iCloud or cross-device sync
- Named saves or multiple concurrent saved games
- Any visible save/restore UI (progress indicators, confirmation messages)
- Migration tooling for saved state across major schema changes (silent discard per FR-06 is sufficient)

---

## Open Questions

None — all decisions are resolved in this document.

---

## Success Metrics

| ID | What's Being Verified | Pass Condition |
|---|---|---|
| QA-01 | Restore after quit | Game in progress → quit app → reopen → scoring view shows with all rounds and player names intact |
| QA-02 | Restore after long background | Game in progress → background app for 10+ minutes → return → state fully preserved |
| QA-03 | Clear on "End Game" | Mid-game → tap "End Game" → confirm → quit and reopen → setup screen appears (no restore) |
| QA-04 | Clear on "Start Fresh" | Win screen → tap "Start Fresh" → quit and reopen → setup screen appears |
| QA-05 | Clear on "New Game — Same Players" | Win screen → tap "New Game — Same Players" → quit and reopen → setup screen appears (or new game in progress, not old one) |
| QA-06 | Clear on new game start | Setup screen → tap "Start Game" → quit before any round → reopen → setup screen (new game state cleared since no rounds yet) |
| QA-07 | Corrupt state handled silently | Manually corrupt saved state file → reopen app → setup screen appears, no crash, no error shown |
| QA-08 | In-progress entry not saved | Score entry sheet open → force-quit → reopen → current round entry is not pre-filled; user must re-enter |
| QA-09 | Win screen survives quit | Game over (player reaches 100) → quit from win screen → reopen → win screen (or at minimum, setup — not mid-game state for a completed game) |
| QA-10 | Existing tests pass | All GameSessionTests and GameSetupTests continue to pass |
