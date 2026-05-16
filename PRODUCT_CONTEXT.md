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

### Accessibility (Completed 2026-05-16)

Full accessibility support across all four screens — VoiceOver, Dynamic Type, Reduce Motion, and Increase Contrast.

**What it does:**
- **VoiceOver**: All interactive elements have labels, hints, and traits. Decorative elements (avatars, emoji, drag handle) are hidden from the accessibility tree. Compound rows collapse into a single accessible element with a combined label.
- **Dynamic Type**: All text uses semantic text styles. Two custom-sized titles use `@ScaledMetric(relativeTo:)`: the "Skyjo Scorekeeper" logo (40pt, relative to `.largeTitle`) and the win-screen winner headline (28pt, relative to `.title`).
- **Reduce Motion**: Every animation is wrapped with `reduceMotion ? nil : .easeInOut(…)` via `@Environment(\.accessibilityReduceMotion)`. All transitions and micro-animations are eliminated when the system setting is on.
- **Increase Contrast**: A high-contrast player color palette was added to `Theme` — all eight colors meet WCAG AA (4.5:1) against white. `Theme.playerColor(at:highContrast:)` and `Theme.playerTextColor(at:highContrast:)` accept a `highContrast` parameter. Brand color has a dedicated HC variant (`Theme.brandHighContrast`). Views read `@Environment(\.colorSchemeContrast)` and switch palettes when `colorSchemeContrast == .increased`.
- **Non-color leader indicator**: A `crown.fill` SF Symbol (green, accessibilityHidden) supplements the green dot so the leader is identifiable without relying on color alone.
- **Dynamic Type clipping fix**: All rows with fixed `frame(height:)` changed to `frame(minHeight:)`.

**Files changed:**
- `SkyjoScorekeeper/Theme.swift` — HC palette + `brandHighContrast`; `playerColor(at:highContrast:)` / `playerTextColor(at:highContrast:)` updated signatures
- `SkyjoScorekeeper/Views/GameSetupView.swift` — ScaledMetric title, semantic fonts, reduce motion, HC brand, section header traits
- `SkyjoScorekeeper/Views/PlayerRowView.swift` — VoiceOver label on text field, remove button label, avatar hidden, reduce motion, `minHeight`
- `SkyjoScorekeeper/Views/ScoringView.swift` — header trait, Undo hint, combined row label, crown indicator, `minHeight`, HC colors
- `SkyjoScorekeeper/Views/ScoreEntrySheet.swift` — drag handle hidden, header traits, score field label, negative toggle label+value, doubling preview label, SkyjoChip label+selected trait, all `minHeight`
- `SkyjoScorekeeper/Views/WinView.swift` — ScaledMetric headline, trophy hidden, header trait, combined rank label, HC winner background, `minHeight`
- `SkyjoScorekeeper/Views/EasterEggOverlay.swift` — flower emoji hidden, semantic fonts, HC brand button

**Pipeline artifacts:**
- `pipeline/accessibility/strategic-brief.md`
- `pipeline/accessibility/prd.md`
- `pipeline/accessibility/schema.md`
- `pipeline/accessibility/design-spec.md`
- `pipeline/accessibility/design.html`

---

## Key Decisions

### Player avatar colors use position, not initials
Two players with names starting with the same letter get different colors because color is assigned by position index, not by the name itself. Uses the Okabe-Ito color-blind-safe 8-color palette. Defined in `Theme.playerColor(at:)` and `Theme.playerTextColor(at:)`.

### iOS 17.0 minimum deployment target
Set explicitly in Xcode for both the app target and the test target. The project was originally created on a machine running macOS 26.x which auto-set deployment targets to the host OS version — this caused CI failures until corrected.

### CI uses default Xcode on macos-15, not a pinned version
Pinning to any specific Xcode version is fragile. Xcode 16.2 was originally pinned; it was removed during the accessibility session when `LastUpgradeCheck = 2650` (from the user's local Xcode 26.5) caused actool to fail with Xcode 16.2. The workflow uses `runs-on: macos-15` with no `xcode-select` override. Never add a pinned version back without updating it to match the user's local Xcode.

### CI test destination uses a named simulator, not UDID
The test step uses `-destination "platform=iOS Simulator,OS=latest,name=iPhone 16"`. An earlier UDID-lookup approach (`xcrun simctl list | grep iPhone`) was unreliable — macos-15 runners don't pre-list simulators as "available" without a boot step. The named destination with `OS=latest` resolves correctly with whatever iOS version is installed on the runner.

### "Designed for iPhone" Mac destination is not viable in CI
Attempted as a workaround during the accessibility session. It fails with actool when the iphonesimulator SDK version bundled with Xcode doesn't match the available simulator runtimes on the runner. iOS Simulator destination with code signing disabled (`CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`) is the correct approach.

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

### Standard palette orange/teal/pink-purple don't meet WCAG AA at normal contrast
The Okabe-Ito standard colors are chosen for color-blind safety and visual appeal at normal contrast, not contrast ratio. At normal contrast, several player colors (orange, teal, pink-purple) don't reach 4.5:1 against white. The decision was to leave these as-is — darkening them would compromise the Okabe-Ito color-blind safety design — and rely on the high-contrast palette for users who need WCAG AA compliance.

### Accessibility: use `@Environment` values directly in ButtonStyle
`PrimaryButtonStyle` reads `@Environment(\.colorSchemeContrast)` and `@Environment(\.accessibilityReduceMotion)` inside `makeBody` so that HC brand color and reduced-motion press animation are handled at the button level. This avoids threading contrast/motion state through every call site.

### Accessibility: Font.system text-style overload parameter order
The three-argument text-style overload is `Font.system(_ style:, design:, weight:)` — `design:` comes BEFORE `weight:`. The fixed-size overload `Font.system(size:weight:design:)` has the opposite order. Mixing these up produces a compiler error that mentions `CGFloat.footnote` which is confusing. Always write `.system(.textStyle, design: .rounded, weight: .bold)` (design first).
