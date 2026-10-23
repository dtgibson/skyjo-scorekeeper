## iPhone Duo Optimization

### What this does
Makes Skyjo Scorekeeper right for iPhone Duo (iOS 27.1). When the phone is open like a book, no button, key, chip or toolbar item sits on the fold. Setup, the scoreboard, the win screen and the Easter egg use a two-page layout: the list on the left page, the heading and primary action on the right. The score entry sheet uses the fold as its divider wherever the system presents it across the fold. The fold and camera regions come from SwiftUI's `ReservedRegion`, read in one place in `Theme.swift`. Standard iPhones, iPad and the closed Duo look exactly as before, apart from the Easter egg card on iPad, which now respects the 600pt width cap. CI now builds with Xcode 27.1.

### How to test
1. Open the project in **Xcode 27.1** and run on the **iPhone Duo** simulator (iOS 27.1). Use Device Hub's pose controls for the poses below; the Mac's screen must be unlocked.
2. **Closed (outer display):** setup, scoreboard, entry sheet, win and Easter egg look exactly as on a standard iPhone.
3. **Open:**
   - **Setup:** the players list fills the left page; "Skyjo Scorekeeper", "Who's playing today?", Start Game and the ready note sit on the right page.
   - **Scoreboard:** End Game sits at the left edge and Undo at the right. The bar has no title; "Round N" heads the right page with the rule beneath it, and Enter Round N Scores is pinned at the bottom of the right page.
   - **Entry sheet:** score rows sit left of the fold; "Who ended the round?", the keypad and Confirm sit right of it.
   - **Win:** final standings on the left page; trophy, headline, New Game — Same Players and Start Fresh on the right.
   - **Easter egg** (hold the title for 3 seconds): the card is centred on the right page and grows in from the title.
4. **Tabletop / propped:** setup, scoreboard and win keep the tall layout; only scrolling lists pass the fold. The entry sheet puts its rows above the fold and the chips, keypad and Confirm below. The Easter egg card sits in the upper half.
5. Unfold and fold with a game open: the screen switches arrangement in place, and names or scores already typed are kept.
6. **iPhone 17 and iPad Pro 11-inch (iOS 27):** nothing changes (see "Verification" below).

### Notes for reviewer
- **One home for the fold.** `onAvailableSpace(update:_:)` in `Theme.swift` reads the size plus `ReservedRegion` `.division` (including inactive) / `.occlusion` (active) (only on iOS 27.1+, `#available`-gated) into `AvailableSpace`. A pure initializer classifies the regions: a vertical fold strictly inside the space gives `pages` (leading/trailing frames); a horizontal one gives `upperPage` / `lowerPage`. A fold touching the window's edge (Split View beside the fold) leaves the space undivided. A page starts below any camera region in its top half. `onAvailableSize` now forwards to it, so there is still a single reader, with the same 240ms ease-out / Reduce Motion behaviour.
- **Screens adapt to space and regions only.** Nothing uses `DeviceHinge`, `onHingeChange`, orientation or idiom. Every non-divided path is the shipped layout moved into a `stackedLayout` property, unchanged.
- **D1 (scoreboard title) was applied.** With no fold to avoid, the system centres the inline title on the window's centre line, which is where the fold runs on the open display. The iOS 27.1 UIKit has no fold avoidance for navigation bars. On two pages the bar title is blank and "Round N" (same `"Round %lld"` key) heads the right page with `.isHeader`.
- **Entry sheet fallback was built.** In a 951 × 669pt window the system shows the sheet as a centred ~650pt card regardless of the fitted size. Keys and Confirm landed on the fold (open), and the chips landed on it in tabletop. The sheet now makes the fold its divider instead of resizing its presentation. If the system keeps the sheet on one page, the shipped layouts apply. Details in `decisions.md` (E1).
- **Easter egg (D3):** the card is capped at `Theme.contentMaxWidth`, centred in the page that holds the title, and scales in from the top of that page (ease-out 200ms). It is now presented through a binding so both the backdrop and card transitions run. With Reduce Motion it is instant, per CLAUDE.md (E3).
- **CI:** the job sets `DEVELOPER_DIR: /Applications/Xcode_27.1.app/Contents/Developer`, because the `xcode-27` image defaults to 27.0, which can't compile the 27.1-only API. Drop it once the image default moves; `xcode-select` is still never used. The destination `OS=latest,name=iPhone 17` is unchanged. Locally, under Xcode 27.1 it resolves to iPhone 17 on iOS 27.0, the newest runtime with that device. The image readme lists simulators only on its iOS 27.0 runtime (iPhone 17 included), so it should resolve the same way there; confirm on the first CI run.
- **No new strings, no new files, no project changes.** Nothing needs dragging into Xcode.

### Verification
- `xcodebuild test`, iPhone 17 (iOS 27.0), Xcode 27.1: **74 / 74 passed** (71 existing + 3 new in `AdaptiveLayoutTests`). The Duo frames in the existing size test now use the simulator's real sizes, replacing the guessed 660×504. Release build for the generic simulator succeeded with no Swift warnings.
- **No-change check:** screenshots of setup (8 players), scoreboard, entry sheet, win and Easter egg were taken with the `HEAD` build and this build, then pixel-diffed. They are identical on iPhone 17, iPad Pro 11-inch portrait and landscape, and the closed Duo, apart from anti-aliasing, the auto-hiding home indicator, and the intended iPad Easter egg width cap.
- **Open / tabletop:** the Mac's screen was locked for the whole session, so Device Hub's pose controls couldn't be used and the Duo simulator stayed closed. The layouts were checked on the iPhone Duo simulator (iOS 27.1) in a 951 × 669 / 669 × 951pt app window, with a temporary fake 24pt fold at the centre (removed before hand-off). See `pipeline/iphone-duo-optimization/screenshots/*-simfold-*` (fold drawn in red).
- **The open-pose screenshots used a landscape-enabled build.** To get the 951 × 669pt window, the app was built with a command-line override that added landscape to the iPhone orientations; the project file was not changed. The shipped app stays portrait-only on iPhone, and at the open size the simulator holds it to a **501 × 669pt portrait window**. In that window the controls still sit clear of a centred fold, but each page is only about 238pt wide, and **Start Game** and **New Game — Same Players** wrap to two lines. The `*-simfold-*` open screenshots therefore show what the code does when given the full inner display, not what the shipped app gets.
- `weft-design-lint`: clean on all views except one advisory note, the existing 3-second long-press on the title (a gesture duration, not motion).

### Known limitations
- **Unverified: what a real Duo does with a portrait-only app on the open display.** The display may ignore the orientation lock and give the app the full inner display (two-page layout), or hold it to a narrower portrait window (about 501pt wide in the simulator, ~238pt pages, two-line Start Game and New Game — Same Players). This must be confirmed on a device.
- The real fold geometry on a real pose (band width and position) wasn't observed; check it in Device Hub. The fold is read even when the system marks it inactive (e.g. lying flat), so the two pages hold steady through the hinge's whole range (`decisions.md` E4).
- At accessibility text sizes, the setup title wraps on a 463pt page, as it does on narrow iPhones today.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
