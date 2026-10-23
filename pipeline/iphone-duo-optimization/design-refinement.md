# Design Refinement — iPhone Duo Optimization

**Status: approved 2026-10-22, exactly as mocked** — list left / action right, the title on
the right page with Start Game, every screen as shown. Mockup:
`pipeline/iphone-duo-optimization/design.html` (pose switcher: Open · Tabletop · Closed;
player count: 2 · 4 · 8; "Outline tappable areas" and "Reduce motion" toggles; deep links
`?pose=open|tabletop|closed&n=2|4|8`). Every frame reports whether any tappable control
intersects the drawn fold. This document is the build spec; where the mockup and this
text disagree, this text wins.

Extends `pipeline/ios-27-platform-readiness/design-refinement.md` (the previous
refinement of the same screens for any window shape). Nothing in that spec is reversed.

## Visual Direction

Same app, now with a spine. When the offered space contains a vertical fold
(`ReservedRegion(.division)`), the open inner display is treated like an open book: the
scrolling list keeps the **left page**, the screen's heading and its primary action take
the **right page**, and the fold band itself holds nothing. Every token is unchanged:
SF Rounded, `Theme.brand` indigo as the single accent on the primary action,
position-indexed player colours, 14pt cards, 16pt primary button, `Theme.contentMaxWidth`
600pt with the two-frame idiom (a 463pt page never reaches it). The tall iPhone, iPad and
the closed Duo (outer display) look exactly as they do today.

**Rules**

1. **List left, action right** (decided; the user chose this over actions on the left).
   A vertical fold splits today's tall screen into its three bands: heading → top of the
   right page; scrolling list → whole left page; primary action (and its companion
   text/secondary) → bottom of the right page. On setup the title sits on the right page
   with Start Game, not above the list (decided).
2. **The fold is the divider — only if needed.** If the simulator shows the system sheet
   centred across the fold, the score entry sheet keeps its shipped layouts and snaps its
   own divider onto the fold. If the system already keeps the sheet on one page, nothing is
   built for the sheet.
3. **Lists may cross the fold; controls may not.** A horizontal fold (tabletop) keeps
   today's tall layout; only the Easter egg card (and the sheet, conditionally) move.
4. **Adapt by space and regions only.** Never by hinge pose, orientation, idiom or model.
   Fold and camera regions are read in one place in `Theme.swift`.

**Geometry used (from the Evaluator; verify in the simulator)**

| Pose | Window | Fold | `LayoutMode` today |
|---|---|---|---|
| Open | 951 × 669pt | vertical, centred, ~24pt band | `.wide` |
| Tabletop | 669 × 951pt | horizontal, centred, ~24pt band | `.tall` |
| Closed (outer) | 466 × 678pt | none | `.tall` (≈590pt usable, above the 575pt threshold) |

Pages (open): each page = its half minus the band, so ≈463pt wide; content inset 16pt
each side (≈431pt), still capped at 600pt. Camera `.occlusion` sits inside the top safe
area in both inner poses; the helper still reads it so a page's top inset grows if it ever
intrudes.

---

## Screens / Views

### Theme.swift — one home for the regions

Beside `onAvailableSize`, add an `AvailableSpace` reading that carries the size **and** the
division, e.g. `struct AvailableSpace { size: CGSize; division: Division? }` with
`enum Division { case vertical(band: ClosedRange<CGFloat>), horizontal(band: ClosedRange<CGFloat>) }`,
read from `GeometryProxy.reservedRegions(kind: .division)` and `.occlusion`, gated
`#available(iOS 27.1, *)` (nil below). `LayoutMode` keeps its three cases; a screen goes
to pages when `division` is vertical. The same ease-out 240ms / Reduce Motion rule applies
to a change in the division (e.g. unfolding) as to a size change. `AdaptiveLayoutTests`
cover the helper with the frames above.

### GameSetupView

- **Vertical fold (open):** `HStack(spacing: band)` of two pages, each
  `.frame(maxWidth: .infinity)`.
  - Left page: `ScrollView` with the existing `playerSection` (PLAYERS label, rows card,
    Add Player), top padding 24, horizontal 16, capped 600.
  - Right page: `headerSection` (40pt heavy title, tracking −1.5, "Who's playing today?",
    long-press Easter egg intact) at the top with 20pt top padding; `Spacer()`; then the
    existing tall `startSection` (Start `minHeight 58`, note beneath, spacing 11), bottom
    padding 8.
- **Horizontal fold (tabletop) / no fold:** unchanged (tall; short reflow as before).
- **Decisions:** the title lives on the right page so the cover and the call to action
  share a page; the roster gets the full page height. `isShortHeight` is still derived from
  the page's own height so the short reflow still works inside a page.

### ScoringView

- **Toolbar:** End Game (`.cancellationAction`) and Undo (`.primaryAction`) stay as the
  system places them — one at each side edge, i.e. one per page — as word-and-symbol
  capsules (`toolbarLabel`, unchanged). Verify in the simulator that neither sits in the
  band; if the system ever centres an item, give it a `.topBarLeading` / `.topBarTrailing`
  placement explicitly.
- **Title:** on the divided layout the inline `navigationTitle` would be centred on the
  spine. There, set `.navigationTitle("")` and render **"Round N"** as the heading of the
  right page: `@ScaledMetric(relativeTo: .largeTitle) 34pt`, `.heavy`, `.rounded`, brand
  colour (HC variant when `colorSchemeContrast == .increased`), tracking −0.8, centred,
  `.accessibilityAddTraits(.isHeader)`; the existing caption ("Game ends when someone
  reaches 100. Lowest total wins.", `.caption`, secondary) 10pt below it, centred. Right
  page top padding = toolbar height + 20. Same string key `"Round %lld"`.
- **Left page:** `ScrollView` with `standingsCard` only (caption moved to the right page),
  top padding under the toolbar 16, capped 600.
- **Right page bottom:** `enterButton` unchanged (`minHeight 58`), horizontal 16, bottom 8.
- **Tabletop / closed:** unchanged.

### ScoreEntrySheet — only if the system sheet straddles the fold

First check in the Duo simulator. Expected: the system presents the fitted/form sheet on
one page, where its width (<560pt) yields the stacked layout and nothing is built. If
instead the sheet is centred across the crease:

- **Fallback A — vertical fold:** present the sheet spanning the window with 24pt side
  margins (height = fitted height as today, clamped to the window). The side-by-side layout
  applies with these overrides: `rowsColumn` width = left page width − 24pt margin;
  the `Divider` is removed and the `HStack` spacing = the band width; `controlsColumn`
  fills the right page (no fixed 284pt). Keys stretch to the page, `minHeight 44`, numpad
  `maxHeight 320`. Chips stay a two-column grid. Confirm pinned bottom-right.
- **Fallback B — horizontal fold (tabletop):** present the sheet tall (top at safe-top +
  76, bottom at safe-bottom, 16pt side margins). Rows `ScrollView` above the band, fixed to
  the upper page's remaining height; below the band in order: WHO ENDED THE ROUND? as the
  single-row chips style (hint hidden), numpad (keys grow to fill, `minHeight 44`,
  `maxHeight 260` total), Confirm (`minHeight 52`). Rows scroll inside the upper page from
  six players.
- Entry state stays in the sheet's `@State` so a live pose change keeps what's typed.
  VoiceOver order unchanged: rows → who ended → numpad → Confirm.

### WinView

- **Vertical fold (open):** two pages.
  - Left page: `ScrollView` with `rankingsCard` (FINAL STANDINGS), top padding 24, capped
    600; scrolls only from six players.
  - Right page: the **tall hero** (`tallHero`: 52pt spacer, 64pt emoji, 28pt heavy
    headline, subtitle, tie-broken note) with its gradient background, then `Spacer()`,
    then the **stacked actions** (`stackedActions`: New Game — Same Players `minHeight 58`,
    Start Fresh text button `minHeight 44`), bottom padding 8.
  - `isCompact` is false on the divided layout even though the window is `.wide`: pages
    decide before size does.
- **Tabletop / closed:** unchanged (tall).

### EasterEggOverlay

- The card now respects `Theme.contentMaxWidth`: width = min(600, container − 48).
- **Vertical fold:** the card centres within the **right page** (the page that holds the
  title it came from); `.transition(.scale(scale: 0.9, anchor: <title's unit point in the
  page>).combined(with: .opacity))`.
- **Horizontal fold:** the card centres within the **upper page**, 600pt wide.
- **No fold:** centred as today. Close button and material tap-to-dismiss unchanged.

---

## Component Usage

- `HStack(spacing: band)` + two `VStack` pages, each `.frame(maxWidth: .infinity)`; no
  new container types, no `GeometryReader` outside `Theme.swift`.
- Existing `PrimaryButtonStyle`, `PlayerRowView`, `StandingRowView`, `FinalRankRow`,
  `ScoreInputRow`, `SkyjoChip`, `toolbarLabel`, system `NavigationStack` toolbar, system
  `.sheet` presentation — all reused unchanged.
- No new third-party dependencies, no custom bar or sheet chrome.

## Design Tokens Applied

- `Theme.brand` / `Theme.brandHighContrast`: primary buttons, Round N heading, title,
  hero headline, toolbar tint.
- `Theme.playerColor(at:highContrast:)` / `playerTextColor`: avatars and chips by position.
- `Theme.contentMaxWidth` (600): every page column and the Easter egg card.
- Radii 14 (cards) / 16 (primary) / 13 (Easter egg Close, as shipped) / 22 (card) / 10
  (keys, chips).
- Type: SF Rounded; new size: Round N heading 34pt heavy (`.largeTitle`-scaled). All others
  as shipped (40 title, 28 hero, 26/24 compact).
- Semantic colours unchanged (`systemGroupedBackground`, `systemBackground`, green/orange/
  red statuses).

## Interaction Notes

- Unfold / fold (outer ↔ inner) and tabletop ↔ open are size + region changes; every
  screen re-derives its mode and pages from `onAvailableSpace`; view state lives above the
  page subviews (names typed, entry inputs, focused row).
- Toolbar items keep their actions and the Undo disabled state; the End Game alert and
  the win `fullScreenCover` are unchanged and still derive from `session.isGameOver`.
- Split View on Duo: a half-width window has no division → today's layouts; no special case.

## Motion Spec

- Pages appear/disappear (unfold, tabletop ↔ open): ease-out, 240ms, origin top-leading
  (the list stays put, heading and action slide to their page), reduced-motion → instant;
  SwiftUI `withAnimation(.easeOut(duration: 0.24))` in `AvailableSpaceReader`, same as size.
- Easter egg card: scale 0.9 → 1 + opacity, ease-out, 200ms, origin = the title's position
  within its page, reduced-motion → opacity only; `.transition(.scale(anchor:).combined(with: .opacity))`
  with `.animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: showEasterEgg)`.
- Entry sheet fallback column swap (A ↔ B on a pose change): ease-out, 240ms, origin
  top-leading, reduced-motion → instant; same `layoutMode` animation as shipped.
- Everything else (press scale 0.985/100ms, focus ring 100ms, chip 120ms, key 90ms,
  system toolbar/sheet motion): unchanged from the iOS 27 spec.

All custom animations are wrapped `reduceMotion ? nil : …` per CLAUDE.md.

## Content Notes

- **No new strings.** "Round %lld" is reused as a page heading; the caption, "N players
  ready", Start Game, Enter Round N Scores, New Game — Same Players, Start Fresh, Close and
  the Easter egg message move position only. Add nothing to `Localizable.xcstrings` unless
  the toolbar needs explicit placements with new labels (not expected).
- **Accessibility:** the Round N heading carries `.isHeader`; VoiceOver reading order on
  the divided layout is left page then right page (list → heading → action), which matches
  today's top-to-bottom order except that the heading follows the list — acceptable, and
  the winner announcement on appear still fires first. All targets ≥ 44pt; `minHeight`
  everywhere; Increase Contrast variants everywhere brand or player colour appears.
- **Out of scope, confirmed:** no pose-specific layouts (`DeviceHinge` unused), no new
  screens or data, app icon unchanged.
