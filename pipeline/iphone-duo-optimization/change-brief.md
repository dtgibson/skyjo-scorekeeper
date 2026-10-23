# Change Brief — iPhone Duo Optimization

## What is changing
Make every existing screen feel right on iPhone Duo (iOS 27.1) in every pose: closed (outer
display), open (inner display), half-open like a book, propped or tabletop, portrait and
landscape, and in Split View. The core fix is that no tappable control sits in the fold.
Today every screen centres a 600pt column, so on the open inner display (951×669pt) the fold
runs straight through it and the pinned buttons (Start Game, Enter Round N Scores, New Game /
Start Fresh, the Easter egg's Close) sit across it. The fold and camera regions are read with
SwiftUI's `ReservedRegion` (iOS 27.1, gated `#available`), with one home in `Theme.swift`
beside `onAvailableSize`, and existing content is arranged around them. Also covered: the
scoreboard's system toolbar once it moves to the side edge, the shorter outer display
(466×678pt), and rebuilding with Xcode 27.1 for Duo's edge-to-edge layout.

## Scope
Changes: `Theme.swift` (fold-avoidance helper), `Views/GameSetupView.swift`, `Views/WinView.swift`,
`Views/ScoringView.swift` (pinned button; toolbar labels in the side-edge layout),
`Views/EasterEggOverlay.swift` (Close button; its card also ignores the 600pt cap),
`SkyjoScorekeeperTests/GameSessionTests.swift` (`AdaptiveLayoutTests`),
`.github/workflows/pipeline.yml` (build on Xcode 27.1), `CLAUDE.md` (Layout and CI conventions).
Only if the simulator shows a need: `Views/ScoreEntrySheet.swift` (system sheets are meant to
avoid the fold on their own) and `Localizable.xcstrings` (no new strings expected).
Unchanged: models, scoring, persistence, `Route` navigation, `PlayerRowView.swift`, brand colour
and type, the iPhone portrait lock, the iOS 17.0 target, the `.xcodeproj`. No pose-specific
layouts: `DeviceHinge`/`onHingeChange` stay unused, screens adapt to space and regions only.

## Why now
iPhone Duo ships tomorrow (2026-10-23) on iOS 27.1. Xcode 27.1 went final on 2026-10-15
(27A9275) and the App Store has taken 27.1 SDK builds since 2026-10-05, which clears the
blocker DECISIONS.md set for this roadmap item. Checked today: local Xcode is 27.1 (27A9275)
with the iOS 27.1 SDK, which declares `ReservedRegion` (kinds `.division` and `.occlusion`,
read via `GeometryProxy.reservedRegions(kind:)`), plus an iPhone Duo simulator on the 27.1
runtime. `xcode-select` points at Command Line Tools, so build with
`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. CI's `xcode-27` image has 27.1
installed but still defaults to 27.0, which can't compile 27.1-only API. The last build's "Duo"
checks used a guessed 660×504 frame; the simulator's real sizes are 466×678pt outer and
951×669pt inner (open).

## User-facing impact
Only on iPhone Duo. Pinned buttons move clear of the fold on the inner display, and existing
content is arranged around it (The Designer decides how). The scoreboard's End Game, Undo and
"Round N" follow the system to the side edge. The app gets Duo's edge-to-edge layout and the App
Store's "optimized for iPhone Duo" badge. Standard iPhones and iPad look and work exactly as
today: they have no fold region and the new code is gated to iOS 27.1. No new screens,
information or data.

## Design pass
Needed. The fold splits the open inner display through today's centred column, so where the
pinned actions go is a layout decision on existing surfaces:
- GameSetupView: Start Game and the ready note off the fold.
- ScoringView: Enter Round N Scores off the fold; toolbar labels read well at the side edge.
- WinView: New Game / Start Fresh off the fold; hero and standings arranged around it.
- EasterEggOverlay: Close off the fold.
- ScoreEntrySheet: design only if the system sheet doesn't keep numpad, chips and Confirm clear.
Rearrange existing content only; scrolling lists may pass through the fold. Also check the
outer display (466×678pt, near the 575pt short threshold) and tabletop (fold runs across).

## Decisions touched
- iOS 27 out-of-scope list, "revisit `ReservedRegion` once Xcode 27.1 is final": fulfilled.
- iOS 27 "screens adapt by the space their window offers" + Key Decision "single contentMaxWidth
  cap": extended. Fold and camera regions become part of the space offered, one home in
  `Theme.swift`. The 600pt cap stays; any off-centre column around the fold gets logged.
- iOS 27 CI "`runs-on: xcode-27`, image default Xcode, no `xcode-select` pin": modified. The
  app ships on 27.1 but the image defaults to 27.0; "build with the Xcode the app ships with"
  wins. Select 27.1 narrowly, note to drop it once the image default moves, and confirm
  `OS=latest,name=iPhone 17` still resolves (locally the 27.1 runtime has only iPhone Duo).
- Kept: system toolbar, iOS 17.0 target with `#available` gating, two windows share one game.

## What done looks like
In the iPhone Duo simulator (Xcode 27.1), setup, scoreboard, entry sheet, win and the Easter
egg are checked closed, open, half-open, propped/tabletop and flipped, in portrait, landscape
and Split View: no button, key, chip or toolbar item sits in the fold or camera region, and
nothing clips. iPhone 17 and iPad Pro 11-inch match today's screenshots. All 71 tests pass
plus new fold-helper tests, and CI builds and tests on Xcode 27.1. Poses may need switching by
hand in Device Hub rather than by script.
