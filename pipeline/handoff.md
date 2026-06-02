# Handoff — Session Persistence (Complete)

**Feature:** Session Persistence
**Status:** Complete — both sessions done, deployed, chronicled
**Date:** 2026-05-24

---

## What was built

Active games are now automatically saved to disk and restored on next launch. If a player closes the app mid-game — whether by switching apps, killing it, or just walking away — they come back to exactly where they left off: same players, same scores, same round number.

The app opens to the scoring view when a saved game is found. It opens to the setup screen otherwise. Completed games (any player hitting 100) are cleared immediately so the app never wakes up in a finished state. Starting a new game always clears any saved state.

The feature adds no visible UI — the behavior is invisible except in the moment it matters.

---

## All artifacts and files

**Pipeline artifacts (Session 1):**
- `pipeline/session-persistence/strategic-brief.md`
- `pipeline/session-persistence/prd.md`
- `pipeline/session-persistence/schema.md`
- `pipeline/session-persistence/design-spec.md`
- `pipeline/session-persistence/design.html`

**New source files:**
- `SkyjoScorekeeper/Models/GameSessionSnapshot.swift`
- `SkyjoScorekeeper/Models/SessionStore.swift`
- `SkyjoScorekeeperTests/SessionPersistenceTests.swift`

**Modified source files:**
- `SkyjoScorekeeper/Models/Player.swift` — added `Codable`
- `SkyjoScorekeeper/Models/RoundScore.swift` — added `Codable`
- `SkyjoScorekeeper/Models/Round.swift` — added `Codable`
- `SkyjoScorekeeper/Models/GameSession.swift` — `init(snapshot:)`, `snapshot` computed property, save/clear in `commitRound` and `undoLastRound`
- `SkyjoScorekeeper/SkyjoScorekeeperApp.swift` — launch restore logic, `Route.game(session:)` carries injected `GameSession`
- `SkyjoScorekeeper/Views/ScoringView.swift` — `init(session:onNewGame:)` accepts injected session

**Context files updated:**
- `PRODUCT_CONTEXT.md` — session-persistence feature entry added; "No data persistence" decision superseded
- `DECISIONS.md` — five new decisions covering snapshot pattern, storage location, silent failures, game-over clear, injected session
- `ROADMAP.md` — features shipped: 7; last shipped updated
- `CLAUDE.md` — Session Persistence conventions section added

**Commits:**
- `874f986` — feat: persist active game session across app restarts
- `8ef47a5` — chore: context update after session-persistence

---

## This feature is complete

CI passed. All 12 new tests green. Context fully updated.

---

## Starting the next feature

Run `/new-feature` — your roadmap's Up Next section is currently empty, so you'll be asked what to build next.
