# Product Context

This file is maintained by The Chronicler.
It records what has been built and key decisions made during development.

---

## Features Built

### Game Setup (Completed 2026-05-09)

The app's launch screen. Handles all pre-game configuration before a round of Skyjo begins.

**What it does:**
- Displays 2 empty player name fields on cold launch (min 2, max 8)
- Add Player button adds rows; hides automatically at 8 players
- Remove button appears on each row when more than 2 players are present
- Start Game button is disabled until at least 2 non-blank names are entered
- Blank fields mixed with filled fields are highlighted in red on a failed start attempt
- Names are trimmed of whitespace before validation and use
- Play-again flow: accepts pre-populated `[Player]` on init (from win screen via `onNewGame`)
- Easter egg: 3-second long-press on the "Skyjo Scorekeeper" title reveals "Happy Mother's Day, Shawn!" as a frosted glass overlay

**Files:**
- `SkyjoScorekeeper/Models/Player.swift` — `Player` struct (id: UUID, name: String)
- `SkyjoScorekeeper/Models/GameState.swift` — `ObservableObject` managing player list, validation, add/remove logic
- `SkyjoScorekeeper/Views/GameSetupView.swift` — main view with header, player list, start section; wired to `onStart` callback for navigation
- `SkyjoScorekeeper/Views/PlayerRowView.swift` — individual player row with avatar, text field, remove button
- `SkyjoScorekeeper/Views/EasterEggOverlay.swift` — frosted glass modal overlay
- `SkyjoScorekeeper/Theme.swift` — brand color + Okabe-Ito 8-color player palette
- `SkyjoScorekeeperTests/GameSetupTests.swift` — 10 unit tests (all passing)

**Pipeline artifacts:**
- `pipeline/game-setup/strategic-brief.md`
- `pipeline/game-setup/prd.md`
- `pipeline/game-setup/schema.md`
- `pipeline/game-setup/design-spec.md`
- `pipeline/game-setup/design.html`

---

### Score Tracking (Completed 2026-05-11)

The active game screens. Takes players from setup through scoring rounds to a winner, with full Skyjo rules enforcement.

**What it does:**
- Root navigation via `Route` enum in `SkyjoScorekeeperApp` — switches between setup and game without NavigationStack
- **Scoring view**: shows standings sorted ascending (lowest score first), leader highlighted with green dot and tinted row background, round number in nav bar, "End Game" button (top-left, shows confirmation alert then returns to setup), Undo button (disabled on round 1), "Enter Round N Scores" primary button
- **Score entry sheet**: bottom sheet (`.large` detent) with per-player score inputs and a Skyjo question section; "Confirm" button disabled until all scores entered and Skyjo question answered
- **Doubling rule**: if a player calls Skyjo but doesn't have the lowest raw score, their score is doubled; a live "×2 → N" preview appears next to their name in the entry sheet
- **Undo**: removes the most recent round from `GameSession.rounds`, restoring all totals to their previous state
- **Game over**: triggered when any player's cumulative total reaches 100; transitions to win screen via `fullScreenCover`
- **Win screen**: hero section with winner name and emoji, final standings with 🥇🥈🥉 medals, red totals ≥ 100, two action buttons ("New Game — Same Players" and "Start Fresh")
- **Tiebreaker**: when multiple players are tied for lowest total, the winner is the one with the lowest score in the final round; if still tied, all are declared co-winners

**Files:**
- `SkyjoScorekeeper/Models/RoundScore.swift` — per-player score for one round (raw + applied after doubling)
- `SkyjoScorekeeper/Models/Round.swift` — one completed round (number, scores, skyjoPlayerID)
- `SkyjoScorekeeper/Models/PlayerStanding.swift` — computed standing (total, isLeader, lastRoundScore)
- `SkyjoScorekeeper/Models/GameSession.swift` — `ObservableObject` scoring engine; owns rounds, computes standings, enforces doubling, determines winners
- `SkyjoScorekeeper/Views/ScoringView.swift` — main scoreboard with `StandingRowView`
- `SkyjoScorekeeper/Views/ScoreEntrySheet.swift` — score input sheet with `ScoreInputRow` and `SkyjoChip`
- `SkyjoScorekeeper/Views/WinView.swift` — win screen with `FinalRankRow`
- `SkyjoScorekeeper/SkyjoScorekeeperApp.swift` — root `Route` enum navigation (setup ↔ game)
- `SkyjoScorekeeperTests/GameSessionTests.swift` — 27 unit tests covering all scoring logic (all passing)

**Pipeline artifacts:**
- `pipeline/score-tracking/strategic-brief.md`
- `pipeline/score-tracking/prd.md`
- `pipeline/score-tracking/schema.md`
- `pipeline/score-tracking/design-spec.md`
- `pipeline/score-tracking/design.html`

---

### iPad Layout (Completed 2026-05-16)

Adapts all four screens to display natively on iPad by constraining content to a maximum width and centering it. iPhone layout is unchanged.

**What it does:**
- All four screens (GameSetupView, ScoringView, ScoreEntrySheet, WinView) center their primary content within a 600pt maximum width column on iPad
- On iPhone (screen width < 600pt), layout is pixel-identical to before — the constraint has no effect
- iPad is now a supported device destination in the Xcode target (previously iPhone-only, which caused the app to run in scaled compatibility mode on iPad)

**Files changed:**
- `SkyjoScorekeeper/Theme.swift` — `Theme.contentMaxWidth: CGFloat = 600` added as the single source of truth
- `SkyjoScorekeeper/Views/GameSetupView.swift` — player list and start button constrained
- `SkyjoScorekeeper/Views/ScoringView.swift` — nav bar, standings card, enter button constrained
- `SkyjoScorekeeper/Views/ScoreEntrySheet.swift` — scroll content and confirm button constrained
- `SkyjoScorekeeper/Views/WinView.swift` — hero section, rankings card, action buttons constrained; winner row background opacity bumped 0.06 → 0.18

**Pipeline artifacts:**
- `pipeline/ipad-layout/strategic-brief.md`
- `pipeline/ipad-layout/prd.md`
- `pipeline/ipad-layout/schema.md`
- `pipeline/ipad-layout/design-spec.md`
- `pipeline/ipad-layout/design.html`

---

## Key Decisions

### Player avatar colors use position, not initials
Two players with names starting with the same letter get different colors because color is assigned by position index, not by the name itself. Uses the Okabe-Ito color-blind-safe 8-color palette. Defined in `Theme.playerColor(at:)` and `Theme.playerTextColor(at:)`.

### iOS 17.0 minimum deployment target
Set explicitly in Xcode for both the app target and the test target. The project was originally created on a machine running macOS 26.x which auto-set deployment targets to the host OS version — this caused CI failures until corrected.

### CI uses default Xcode on macos-15, not a pinned version
Pinning to Xcode 16.2 caused CI failures because the available simulator runtimes on the runner (iOS 18.5+) were installed for newer Xcode. The workflow uses `runs-on: macos-15` with no `xcode-select` override; as of 2026-05-09 this resolves to Xcode 16.4.

### CI simulator is resolved by UDID at runtime
Instead of pinning an OS version (e.g. `OS=18.5`), the workflow uses `xcrun simctl list` to find the first available iPhone 16 and passes its UDID to xcodebuild. This stays correct as the runner image updates over time.

### "Designed for iPhone" Mac destination is not viable in CI
Attempted as a workaround when iOS simulators weren't found. macOS requires a valid developer certificate to install iOS apps via this pathway — ad-hoc signing is rejected. iOS Simulator destination with code signing disabled (`CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`) is the correct approach.

### No data persistence
All game data is fully in-memory. Nothing is persisted between app launches. Intentional per the PRD — out of scope for both features built so far.

### Root navigation uses a Route enum, not NavigationStack
`SkyjoScorekeeperApp` owns a `@State private var route: Route` with cases `.setup` and `.game`. Switching routes replaces the entire view tree. This avoids NavigationStack complexity for an app with only two top-level screens.

### Doubling rule: applies when Skyjo caller's score is >= minimum of other players
If the player who called Skyjo scores the same as the lowest other player (a tie), they ARE doubled — only strictly less than all others escapes doubling. Implemented in `GameSession.commitRound` by computing `otherMin` (minimum of other players' scores, excluding the caller), then doubling when `raw >= otherMin && raw > 0`. An earlier implementation used `raw > minRaw` (including the caller in the minimum), which incorrectly let ties escape — this was corrected.

### Skyjo question must be answered before confirming a round
The confirm button in `ScoreEntrySheet` requires `skyjoAnswered == true` (either a player selected, or "Nobody" tapped). This prevents accidentally skipping the doubling rule.

### iPad layout uses a single contentMaxWidth constant and the two-frame idiom
All four screens reference `Theme.contentMaxWidth` (600pt) — no view hardcodes a width. The SwiftUI pattern for constrained+centered content is the two-frame idiom: `.frame(maxWidth: Theme.contentMaxWidth).frame(maxWidth: .infinity)`. The inner frame caps width; the outer frame centers it. New views that have primary content should follow this pattern for iPad compatibility.

### iPad is a supported device destination
The Xcode target was updated to include iPad alongside iPhone. The app was previously "Designed for iPhone" only, which caused it to run in scaled compatibility mode on iPad. All new screens must work correctly on both device families.

### Project file (xcodeproj) is generated, not hand-maintained
The `.xcodeproj` package was regenerated by hand after the original was accidentally deleted. The source of truth for which files exist is the iCloud directory; the project file references them by path. Both the git repo and the iCloud working directory have the same flat layout: all source files (`*.swift`, `Assets.xcassets`, `PrivacyInfo.xcprivacy`) sit directly alongside the `.xcodeproj` in `SkyjoScorekeeper/`. The test files (`GameSessionTests.swift`, `GameSetupTests.swift`) live in `SkyjoScorekeeperTests/` at the repo root, one level above the `.xcodeproj` — matching the pbxproj group path `../SkyjoScorekeeperTests`.
