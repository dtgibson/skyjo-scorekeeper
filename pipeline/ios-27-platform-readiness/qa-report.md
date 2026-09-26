# QA Report — iOS 27 Platform Readiness

**Date:** 2026-09-26
**Test Runner:** XCTest via `xcodebuild` (Xcode 27.0, `pipeline.config.json` `stack.testRunner` is null)
**Verification tier:** 2 — Full weave
**Result:** PASSED

## Verification scope

- **Tier 2 (Full weave)** from `weft-scope classify` (base `383fa53`, 8 files):
  - classes `logic, security-surface`
  - trigger `ci-deploy`, from `.github/workflows/pipeline.yml`
  - Tier 2 was the floor, so no escalation was needed. xcodebuild has no runner-native affected-test mechanism, so Tier 1 wasn't possible anyway.
- **Brief-vs-diff cross-check:** the brief isn't cosmetic, so a `logic` class is expected. The one non-UI logic change is the `GameSession.commitRound` guard (ignore rounds after game over). It is **within scope**: the research's R4 says "no scoring past game over" in its two-window recommendation. `ScoringView` is the only caller, and the UI never allowed a commit after game over before, so single-window behavior is unchanged. The `security-surface` tag comes from the session model and tests. No persistence format, network, or auth code changed.
- **What ran:**
  1. **Full suite, exact CI command.** `xcodebuild test … -destination "platform=iOS Simulator,OS=latest,name=iPhone 17"` on Xcode 27.0. It ran twice, the second time from a clean DerivedData folder. Destination resolved to iPhone 17, iOS 27.0 (24A434).
  2. **CI Release build step, exact command.** `-configuration Release -destination "generic/platform=iOS Simulator"`.
  3. **Before/after screenshots on the iPhone 17 (iOS 27) simulator.**
     - The base commit and this build were compared screen by screen: setup, scoreboard at round 1 and round 4, entry sheet with 4 and 8 players (with values typed), and win.
  4. **Layout checks on iPhone 17 and iPad Pro 11-inch (M5), both iOS 27:**
     - Real sheet presentations with 2, 4 and 8 players.
     - Framed containers:
       - iPhone Mirroring short: 393×460 and 400×520
       - iPhone Duo: 660×504
       - Landscape-like: 820×560
     - Live resizes with typed values: tall→short on iPhone, wide→tall on iPad.
  5. **Two-window check.**
     - On iPhone, the scoreboard had its entry sheet open while the game ended from outside. This is the other-window case.
     - On iPad, a real second window (scene) was created, then the game ended.
  6. **Accessibility:**
     - Largest text size tested at AX3 (`accessibility-extra-large`).
     - Increase Contrast on.
     - Source checks: Reduce Motion gating, `minHeight` use, no orientation/idiom checks, and every changed string in `Localizable.xcstrings`.
- **Harness hygiene.** Screen-forcing code (launch-argument scenarios, fixed frames, seeded input) went only into two throwaway copies in the session scratchpad. The repository was never edited. Afterwards:
  - The harness app was uninstalled from both simulators and the simulators were shut down.
  - Text size and contrast were reset.
  - `git diff` is unchanged: The Engineer's 10 files, +644/−156.
  - There are no harness references in the repo.
- **Deliberately skipped, never silent:**
  - **The GitHub `xcode-27` runner itself was not exercised.** That needs a push. The label and the `iPhone 17` simulator on that image are confirmed by the runner-images readme and changelog cited in `platform-research.md`. The same commands passed locally on Xcode 27.0.
  - **The iOS 17 fallback path was not run.** No iOS 17 or 18 runtime is installed; only 26.4, 26.5 and 27.0 are. It is compile-verified: the deployment target is 17.0, `presentationSizing` is gated `#available(iOS 18, *)`, and the compiler enforces availability.
  - **No real iPhone Duo or iPhone Mirroring.** Duo needs Xcode 27.1 beta and Mirroring needs hardware. Both were covered with frames of the same size.
  - **Two windows were not seen side by side.** The simulator runs in full-screen-apps mode. The background window's update is confirmed from the system log instead.
  - **Reduce Motion and VoiceOver were not toggled at runtime.** `simctl` has no switch for them. They were verified by source inspection.

## Test Results

- **71 tests run: 71 passed, 0 failed, 0 skipped.**
  - The count is from the result bundle, and both runs matched.
  - Breakdown: GameSessionTests 43, SessionPersistenceTests 15, GameSetupTests 10, AdaptiveLayoutTests 3.
- **New tests in this build (4), all passing first time:**
  - `testCommitRoundIgnoredAfterGameOver`
  - `testLayoutModeFollowsAvailableSpace`
  - `testLayoutModeBoundaries`
  - `testFittedEntryPanelHeightFollowsPlayerCount`
- **Release build:** BUILD SUCCEEDED.
- **Compiler warnings:** none from app or test sources. The only warnings are the toolchain's AppIntents metadata notices.
- **NEW failures:** none.
- **KNOWN pre-existing failures:** none.
- **Baseline:** `weft-scope baseline check` returned BOOTSTRAP. The full suite had run clean, so the baseline was recorded with 0 failures (`pipeline/baseline-failures.json`). A re-check reads `new=0 known=0 resolved=0`.
- **RESOLVED baseline entries:** none.

## Acceptance Criteria Verification

| Criterion | Result | Notes |
|---|---|---|
| App builds on Xcode 27 | ✓ Pass | CI test build and CI Release build commands both succeed on Xcode 27.0 / iOS 27.0 SDK. They also succeed from a clean DerivedData. |
| All tests pass on Xcode 27, iPhone 17 destination | ✓ Pass | 71/71 using the exact CI destination string (`OS=latest,name=iPhone 17`), which resolves to iOS 27.0. |
| CI moved to `xcode-27` runner, simulator iPhone 17, no Xcode pin | ✓ Pass | `runs-on: xcode-27`, both commands unchanged apart from the destination name, and no `xcode-select`. The GitHub run itself happens on push (see scope). |
| Standard iPhone portrait looks and works the same (regression) | ✓ Pass | Before/after on iPhone 17 matches for setup, scoreboard, entry sheet (4 and 8 players with values) and win. The only differences are the approved system toolbar and grabber. |
| Scoreboard uses a system toolbar (title + symbol, "Round N" inline, no fixed widths) | ✓ Pass | "End Game" is leading and "Undo" trailing, as glass capsules. Undo is visibly dimmed at round 1. There is no truncation at AX3; the old bar wrapped "End Game" onto two lines. The toolbar spans the window on iPad while the standings stay capped at 600pt. |
| Entry sheet uses the system grabber | ✓ Pass | The custom handle and its padding are removed; the system grabber shows on iPhone and iPad. |
| Entry sheet, short and narrow window (tight stack) | ✓ Pass | Checked at 393×460 with 4 and 8 players and 400×520 with 6. At least two rows stay visible, keys are about 44pt, the hint is hidden, chips sit in one horizontal row that scrolls when needed, and Confirm stays visible. |
| Entry sheet, wide window (side by side) | ✓ Pass | iPad fitted panel with 2, 4 and 8 players: 2 players are centred beside the keypad, and all 8 rows fit. Duo-sized 660×504 with 2 and 8: 8 players scroll, and chips (4 rows), numpad and Confirm fit. Confirm is pinned at the bottom of the right column. |
| Focused row always in view after a tap | ✓ Pass | The focused lower row scrolled into view in the tight stack (Heidi of 8), the real iPhone sheet (Grace), the iPad panel and the Duo frame (Heidi), and after a live layout switch. |
| Typed entries survive a live resize | ✓ Pass | iPhone tall→short and iPad wide→tall. Scores 10–13, the "who ended" choice and the focused row all persisted, and the focused row stayed in view. |
| Win screen stays usable in any shape | ✓ Pass | Tall (iPhone, iPad portrait) is unchanged. Short and wide get a one-line hero and paired actions, with standings in the remaining height. At 393pt wide the icon drops (the Engineer's documented deviation). Duo-sized with 8 players and 820×560 were also checked. |
| Setup screen stays usable in any shape | ✓ Pass | Tall is unchanged, including iPad portrait. Short (393×460 and 660×504): smaller title, "Who's playing today?" hidden, and "N players ready" beside Start Game. |
| Adapt by available space only, never orientation or idiom; width cap kept | ✓ Pass | There are no `UIScreen`, idiom, orientation or size-class checks in app code. Modes come from `LayoutMode(size:)`, measured by `onAvailableSize`. The 600pt cap uses the two-frame idiom throughout. |
| Finishing a game in one window shows the result in every open window | ✓ Pass | All windows share one `GameSession` (the `route` state lives on the `App`). On iPhone, ending the game externally closed the open entry sheet and presented the win screen. On iPad a real second scene was created. After the game ended, the foreground window showed the win screen, and the system log shows both scenes (7AE68FF7 in the background, 21E23F98 in front) refreshing and each presenting a new full-screen presentation. `commitRound` also ignores rounds after game over (unit test). |
| Accessibility: Dynamic Type (AX3, Confirm reachable) | ✓ Pass | At AX3 Confirm stays inside the iPad panel (8 players) and the Duo-sized panel. Keys stay at about 44pt, and the iPhone toolbar and sheet stay usable. |
| Accessibility: Increase Contrast | ✓ Pass | The toolbar tint, "Start Fresh" text and tint, and player colours switch to the high-contrast variants. |
| Accessibility: Reduce Motion, VoiceOver, touch targets | ✓ Pass (source) | Every new or changed animation is gated on `reduceMotion`, and the first layout reading is instant. The toolbar symbol and win emoji are `accessibilityHidden`, and the titles are the labels. The Undo hint and announcements are kept, and the round-recorded announcement semantics are unchanged. The side-by-side sort priority puts rows before controls. Everything uses `minHeight`, with no fixed heights. Not exercised at runtime (see scope). |
| Localization | ✓ Pass | Every touched key exists in `Localizable.xcstrings` with all 35 locales, including "End Game", "Undo", "Round %lld", "Start Fresh", "New Game — Same Players" and "Confirm Round %lld". No new strings were introduced. |

## Known Limitations

Things I ran into during scoped verification. None blocks.

- **Chip names truncate at AX3 in the wide sheet's two-column "who ended" grid.** They show as "Al…", "C…" in the iPad panel and the Duo-sized frame. The Engineer already reported this. The chips remain tappable and correctly labelled for VoiceOver.
- **The iOS 17 fallback (default form sheet, stacked layout) was compile-verified only.** No iOS 17 or 18 simulator runtime is installed on this machine.
- **iPhone Duo and iPhone Mirroring were verified with frames of the same size, not the real device or runtime.** Duo needs Xcode 27.1 (beta).
- **Two windows couldn't be seen side by side in the simulator** (full-screen-apps mode). The background window's update is evidenced by the system log rather than a screenshot. A quick manual pass on a device or simulator with Windowed Apps enabled (`how-to-see.md` §6) would close this.
- **Running `xcodebuild test` shuts down the named simulator** (it clones it for testing). This is a tooling note for anyone scripting screenshots alongside test runs, not an app issue.

## Convention Flags

- **Adaptive layout has one home: `LayoutMode` plus `onAvailableSize(update:_:)` in `Theme.swift`.** It holds the 575pt short height, the 560pt wide minimum and the 1.2 aspect ratio. Views should derive their arrangement from it and never hardcode those numbers or branch on orientation, idiom, `UIScreen` or size class. This works like the existing single-source rules for `isDoubled` and the score thresholds.
