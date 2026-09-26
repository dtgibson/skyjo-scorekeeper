# Change Brief — iOS 27 Platform Readiness

## What is changing
A readiness pass so the app ships on Xcode 27 / iOS 27 and behaves well on iPhone Duo,
in iPhone Mirroring, and in resizable iPad windows. Required: move CI to the Xcode 27
runner (simulator name iPhone 16 → iPhone 17); make the score entry sheet, win screen,
and setup screen work at any window size and aspect ratio (they currently assume a tall
portrait screen); keep two open windows of the app in sync. Recommended: replace the
scoreboard's custom top bar with a system toolbar, use the system sheet grabber, and
rebuild the app icon as a layered Icon Composer file (keep the current icon if a faithful
layered version isn't possible). Full findings and sources: `platform-research.md`.

## Why now
The App Store requires the iOS 27 SDK starting April 2027. iOS 27 makes iPhone apps
resizable and ignores the portrait lock in resizable settings. iPhone Duo ships Oct 23
with a wide inner display that ignores orientation locks and allows two windows of one
app. CI still builds with Xcode 16.4, so it isn't testing what the app ships with.

## User-facing impact
Standard iPhone portrait use looks and works the same. The scoreboard's End Game / Undo
controls become system toolbar buttons (Liquid Glass look). The score entry sheet and win
screen reflow in short or wide windows so scores and standings stay visible. The sheet
shows the system grabber. The app icon may gain layered glass depth. No new screens or data.

## Design pass
Needed. Surfaces: ScoringView top bar → system toolbar (title + symbol per item, no fixed
widths); ScoreEntrySheet → compact-height/wide layout where player rows stay visible
beside or above a numpad with keys ≥ 44pt, plus the system grabber; WinView → compact-height
layout where final standings stay visible and actions stay reachable; GameSetupView →
compact-height check; app icon → layered Icon Composer 2 file (background + "-2" glyph),
with keep-current as the fallback. Adapt by available space or size class, never
orientation or device type. Keep the 600pt width cap.

## Decisions touched
- CI on macos-15 with no Xcode pin (Key Decision + CLAUDE.md CI): modified → `runs-on: xcode-27`
  (image default Xcode 27.0, still no pin). Fallback `macos-26` if the preview image is flaky.
- CI named simulator "iPhone 16": modified → "iPhone 17" (exists on all candidate images).
- Root navigation uses a Route enum, not NavigationStack: kept; ScoringView adds a local
  NavigationStack only to host its toolbar.
- iPad layout / `Theme.contentMaxWidth` two-frame idiom: kept and extended to height.
- iOS 17.0 deployment target: kept (still supported by Xcode 27).
- Project file is user-edited (CLAUDE.md): any build-setting change goes to the user as Xcode steps.
- Localization and accessibility conventions apply to every changed label and layout.

## What done looks like
The app builds and all tests pass on Xcode 27 in CI (`xcode-27` runner, iPhone 17). Every
screen stays usable when resized from tall-narrow to short-wide, with no orientation or
idiom checks. Finishing a game in one window shows the result in every open window.
