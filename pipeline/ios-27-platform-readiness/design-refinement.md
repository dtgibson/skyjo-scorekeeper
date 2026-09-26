# Design Refinement — iOS 27 Platform Readiness

Approved mockup: `pipeline/ios-27-platform-readiness/design.html` (window-shape switcher:
iPhone · iPhone Duo · iPad landscape · iPad portrait · iPhone Mirroring; player-count
switcher: 2 · 4 · 8). This document is the build spec for that mockup. Where the mockup
and this text disagree, this text wins.

## Visual Direction

Same app, any window shape. The tall iPhone portrait screen the user has today stays
visually identical apart from two system components (toolbar, sheet grabber). Every other
change is a *reflow* that only appears when a window is genuinely too short or clearly
wider than tall — iPhone Duo's open display, iPad in landscape, iPhone Mirroring resized
short. The established system holds throughout: SF Rounded, `Theme.brand` indigo as the
single accent on the primary action, position-indexed player colours, 14pt cards, 16pt
primary button, `Theme.contentMaxWidth` (600pt) width cap with the two-frame idiom.

**Non-negotiable rules**

- Adapt by **available space** (the container's own width/height/aspect) or by size class.
  Never by orientation, device idiom, `UIScreen`, or device model.
- Nothing already approved changes at 4 players on the tall iPhone, Duo, iPad landscape,
  or iPad portrait.
- No new screens, flows, or capabilities. The app icon is **out of scope**: the current
  asset-catalog icon (`AppIcon.appiconset`, light/dark/tinted PNGs) is kept unchanged.

**Space rules (used by every screen below)**

| Name | Condition on the container (screen or sheet content) | Used by |
|---|---|---|
| **Tall** | none of the below | everything — today's layout |
| **Short** | available height < **575pt** | entry sheet (tight stack), win, setup |
| **Wide** | available width ≥ **560pt** and (height < 575pt **or** width ÷ height ≥ **1.2**) | entry sheet (side-by-side), win (wide header + paired actions) |

575pt is the stacked entry sheet's minimum height with two player rows visible
(grabber ≈ 22 + header 26 + 2 × 64 + "who ended" ≈ 120 + numpad 248 + Confirm 66). 560pt
is the narrowest width at which a 284pt numpad column leaves ≥ 276pt for player rows.

Preferred SwiftUI mechanism: read the container size once at the top of each screen with
`onGeometryChange(for:)` (iOS 16+ back-deployed) or a `GeometryReader` wrapping only the
root, derive a `LayoutMode` enum (`.tall`, `.short`, `.wide`) from the numbers above, and
switch layouts on it. `ViewThatFits(in: .vertical)` is acceptable for the sheet if it
yields the same outcomes. Do not use `verticalSizeClass == .compact` alone — it misses
resized windows that are short but not "compact".

---

## Screens / Views

### ScoringView — system toolbar

**Layout:** unchanged in every mode. Standings card, caption, and pinned "Enter Round N
Scores" button exactly as today.

**Change:** the hand-built `navBar` HStack (fixed 80pt buttons) is replaced by a system
toolbar with the Liquid Glass look.

- Wrap the view body in a **local `NavigationStack`** whose only job is to host the
  toolbar. The root navigation stays the `Route` enum in `SkyjoScorekeeperApp`; the stack
  never pushes anything. Use `.navigationBarTitleDisplayMode(.inline)`.
- Title: `Round \(session.currentRoundNumber)` via `.navigationTitle` (inline, centred).
- Leading item (`.cancellationAction`): `Button("End Game", systemImage: "xmark")` →
  shows the End Game confirmation alert (unchanged).
- Trailing item (`.primaryAction`): `Button("Undo", systemImage: "arrow.uturn.backward")`
  → `session.undoLastRound()` + the existing VoiceOver announcement. `.disabled` when
  `session.rounds.isEmpty`.
- Both items show **title and symbol** (`.labelStyle(.titleAndIcon)`) so the words stay
  visible; no fixed widths — the system sizes them, so long locales and large Dynamic
  Type never truncate. On iOS 26+ the system renders glass capsules; on iOS 17–18 the
  standard bar. No `presentationBackground` or custom bar chrome.
- Content scrolls under the bar (system scroll-edge effect). Keep the standings
  `ScrollView` as the first child inside the stack so the effect applies.
- The toolbar spans the window; the standings content remains capped at 600pt.

**Accessibility:** the buttons' titles are their VoiceOver labels ("End Game", "Undo").
Keep the existing `.accessibilityHint("Removes the most recent round's scores")` on Undo.
Announcements for undo and round-recorded are unchanged.

### ScoreEntrySheet — stacked / tight / side-by-side

The sheet's content reads its **own** container size (the sheet, not the window).

**Presentation**

- Compact width (iPhone, Mirroring): `.sheet` with `.presentationDetents([.large])` as
  today, **`.presentationDragIndicator(.visible)`** (system grabber). Delete the custom
  `handle` view and its top padding.
- Regular width (iPad, Duo inner display): the system presents a centred form sheet.
  - **iOS 18+:** `.presentationSizing(.fitted)` and give the sheet content
    `.frame(idealWidth: 720, idealHeight: idealHeight(playerCount))` where
    `idealHeight(n) = 344 + chipsBlock(n)`, `chipsBlock(n) = 42 + 44·r + 6·(r − 1)`,
    `r = ⌈n / 2⌉`. Results: **430 (2), 480 (4), 530 (6), 580 (8)**. The system clamps
    to the window, so on Duo (est. ~504pt available) the panel stops at the window and
    the player list scrolls from 6 players up.
  - **iOS 17 fallback:** `presentationSizing` is unavailable; the default form sheet
    (≈ 540 × 620) is shown and the Tall (stacked) layout applies — identical to today
    plus the system grabber. Gate with `if #available(iOS 18, *)`.

**Layout modes**

1. **Tall (stacked)** — today's layout: scroll (rows card, then "who ended the round"
   header + hint + chips grid) / divider / numpad (54pt keys) / "Confirm Round N".
   Only the grabber changes.
2. **Short and narrow (tight stack)** — height < 575 and width < 560 (e.g. Mirroring
   resized): same order, tighter. Numpad keys **44pt** tall, numpad vertical padding 6,
   Confirm `minHeight 50`, hint text hidden, chips become a single horizontally
   scrolling row (each chip ≥ 44pt tall), section spacing 12. At least two player rows
   remain visible; the rest scroll.
3. **Wide (side-by-side)** — width ≥ 560 and (height < 575 or aspect ≥ 1.2), i.e. the
   fitted panel on iPad and Duo:
   - `HStack(spacing: 0)`: **left** = player rows in a `ScrollView`; thin `Divider`
     (0.5pt, 12pt vertical inset); **right** = a **284pt** fixed-width column.
   - Right column, top to bottom: "WHO ENDED THE ROUND?" header (hint hidden) + chips in
     a **2-column `LazyVGrid`** (fixed columns, gap 6, card padding 8) inside a
     `ScrollView` with `minHeight 96` (scrolls only if it must); then the numpad, keys
     `minHeight 44`, growing to fill the column up to ~72pt (numpad padding 6/16/6/12);
     then Confirm (`minHeight 52`, bottom padding 6), pinned at the bottom. Column top
     padding 10.
   - Left column padding 18/12/14/16. Content is **vertically centred when shorter than
     the column** (2 players) and **top-aligned, scrolling** when it overflows (6–8
     players): e.g. `.frame(minHeight: columnHeight)` via `containerRelativeFrame(.vertical)`
     with `.frame(maxHeight: .infinity, alignment: .center)` on the inner stack.
   - With 8 players and 44pt keys, chips (4 rows) + numpad + Confirm fit the Duo panel
     with the paddings above; do not add extra spacing there.

**Scroll-to-focused-row (all modes):** wrap the rows `ScrollView` in a
`ScrollViewReader`; on `focusedPlayer` change call
`proxy.scrollTo(id, anchor: .center)` inside `withAnimation` (respecting Reduce Motion).
The focused row must always be in view after a tap.

**Player counts:** 2 → everything fits, no scrolling, chips one row, panel 430pt tall.
8 → iPad panel (580pt) shows all eight rows; Duo panel clamps and the list scrolls;
tall iPhone scrolls the list exactly as today. Setup hides "Add Player" at 8 as today.

**Unchanged:** `ScoreInputRow` (focus ring, `×2 → N` preview from
`GameSession.isDoubled`), `SkyjoChip`, numpad key semantics and VoiceOver announcements,
`canConfirm` logic, `PrimaryButtonStyle`.

**Accessibility:** every key, chip, and row keeps ≥ 44pt touch targets in all modes. Rows
keep `frame(minHeight: 64)`, chips `minHeight 44`. All existing labels/hints unchanged;
the grabber is a system element (no label needed). The side-by-side `HStack` must keep
VoiceOver reading order: rows first, then "who ended", then numpad, then Confirm — set
`.accessibilitySortPriority` if the default order differs.

### WinView

- **Tall:** unchanged (52pt spacer, 64pt emoji, heavy headline, subtitle, standings,
  stacked actions).
- **Short or Wide** (Duo, iPad landscape, Mirroring short): hero becomes one row —
  emoji at 40pt beside a `VStack` of headline (`title2`-scaled, 24pt base, heavy) and
  subtitle; hero padding 16/24/12, bottom margin 12, gradient background kept. Actions
  become one row: "New Game — Same Players" primary (`flex 3`, `minHeight 52`) and
  "Start Fresh" as a tinted secondary (`Theme.brand` text on `brand.opacity(0.10)`,
  16pt radius, `minHeight 52`, hugging its text, `lineLimit(1)`). Standings `ScrollView`
  takes the remaining height (6 rows on Duo, all 8 on iPad landscape).
- `wasTieBroken` line stays under the subtitle in both arrangements.
- **Accessibility:** unchanged labels; the winner announcement on appear stays. The
  secondary button keeps `minHeight 52` ≥ 44pt.

### GameSetupView

- **Tall / Wide-but-tall (iPad both orientations):** unchanged, including the big title.
- **Short** (height < 575; Duo, Mirroring short): title 26pt (`tracking −0.8`), header
  top padding 12, "Who's playing today?" hidden, list top padding 14, and the status note
  ("N players ready" / "Enter at least 2 names to start") moves **beside** the Start
  button in an `HStack(spacing: 14)` with `lineLimit(1)`; Start `minHeight 52`.
- Keep the 3-second long-press Easter egg on the title in both arrangements.

---

## Component Usage

- `NavigationStack` (local, toolbar host only) + `ToolbarItem` × 2 + `.navigationTitle`.
- `.sheet` + `.presentationDetents([.large])` + `.presentationDragIndicator(.visible)`;
  `.presentationSizing(.fitted)` (iOS 18+) with an ideal frame on the content.
- `ScrollView` + `ScrollViewReader` for player rows; `LazyVGrid` with **fixed** two
  columns for chips in the wide sheet (adaptive 100pt grid stays in the stacked sheet).
- `HStack` / `VStack` + `Divider` for the side-by-side sheet; `Spacer` never used to
  create the numpad column height — the numpad grows via `frame(maxHeight:)`.
- Existing `PrimaryButtonStyle`, `ScoreInputRow`, `SkyjoChip`, `StandingRowView`,
  `FinalRankRow`, `PlayerRowView` reused unchanged.
- No new third-party dependencies. No custom bar or grabber chrome anywhere.

## Design Tokens Applied

- `Theme.brand` / `Theme.brandHighContrast` — toolbar tint (system default tint should
  already resolve to the app accent; verify `AccentColor` = brand), primary buttons,
  focus ring, secondary "Start Fresh" tint (`opacity(0.10)` background).
- `Theme.playerColor(at:highContrast:)` / `playerTextColor` — avatars and chips, always
  by position index (positions 4–7 now appear in the mockup: blue, pink-purple, sky
  blue and yellow with dark text — exactly the existing palette).
- `Theme.contentMaxWidth` (600) — standings, buttons, list content; the system toolbar
  spans the window by design.
- Radii: 14pt cards/rows/chips card, 16pt primary and secondary buttons, 10pt keys and
  chips, capsules from the system.
- Type: SF Rounded throughout (`design: .rounded`); compact win headline 24pt heavy,
  compact setup title 26pt heavy; everything else unchanged.
- Semantic colours: `systemGroupedBackground`, `systemBackground`, `secondarySystemFill`,
  `systemOrange` (danger ≥ `dangerThreshold`), `systemRed` (bust ≥ `bustThreshold`),
  `systemGreen` (leader).

## Interaction Notes

- End Game → existing destructive alert; Undo → existing undo + announcement; Undo
  disabled state must be visually distinct in glass (system handles it).
- Sheet: tap a row to focus (scrolls into view); numpad edits the focused row; tap a
  chip to mark who ended; `×2 → N` preview appears only when `isDoubled` is true;
  Confirm enabled only when all rows filled and a chip is chosen.
- Grabber drag dismisses the sheet as any system sheet.
- Resizing a window (iPad, Mirroring) may switch modes live; state (`rawInputs`,
  `negativeInputs`, `skyjoPlayerID`, `focusedPlayer`) must survive the switch — keep it
  in the sheet's `@State`, not inside the mode-specific subviews.
- Two windows: each window derives its win-screen presentation from `session.isGameOver`
  (R4 in the change brief) — a code decision, no visual change.

## Motion Spec

- Layout mode switch (stacked ↔ side-by-side, hero compact ↔ tall): ease-out, 240ms,
  origin top-leading, reduced-motion → no animation (instant), SwiftUI `.animation(reduceMotion ? nil : .easeOut(duration: 0.24), value: layoutMode)`.
- Scroll focused row into view: ease-out, 240ms, origin n/a (scroll), reduced-motion →
  `proxy.scrollTo` without `withAnimation`, `ScrollViewReader`.
- Focus ring on a row: ease-in-out, 100ms, origin row bounds, reduced-motion → nil,
  existing `.animation(..., value: isFocused)`.
- `×2 → N` preview: opacity + scale 0.85 → 1, ease-in-out, 150ms, origin trailing,
  reduced-motion → nil, existing transition.
- Chip select: ease-in-out, 120ms, origin chip, reduced-motion → nil, existing.
- Numpad key press: scale 0.96, 90ms, origin key centre, reduced-motion → no scale,
  `ButtonStyle` (add a plain pressed style if `.plain` gives no feedback).
- Primary button press: scale 0.985, 100ms, existing `PrimaryButtonStyle`.
- Toolbar glass, sheet presentation, grabber, scroll-edge effect: system motion, nothing
  custom; system honours Reduce Motion.

All custom animations are wrapped `reduceMotion ? nil : …` per CLAUDE.md.

## Content Notes

**New or changed user-facing strings → add to `Localizable.xcstrings`:**

- `"End Game"` and `"Undo"` already exist as `Text`; they now also appear as `Button`
  titles with symbols — same keys, verify the catalog entries are reused.
- `"Round %lld"` as a navigation title (`String(localized:)` if built as a `String`).
- No other new strings. "N players ready" moves position only (same key, plural
  variations unchanged). Hint text is hidden in tight/wide modes, not changed.

**Accessibility requirements (every change):**

- VoiceOver: toolbar buttons labelled by title; row/chip/key labels unchanged; reading
  order rows → who ended → numpad → Confirm in the side-by-side sheet; existing
  announcements kept.
- Dynamic Type: all `frame(minHeight:)` (never `height:`); numpad keys `minHeight 44`
  grow with the row; the wide sheet's 284pt column and 720pt ideal width are fixed but
  content inside wraps/scrolls — test at AX3 that Confirm stays reachable.
- Reduce Motion: every custom animation nil'd; layout switches instant.
- Increase Contrast: `colorSchemeContrast == .increased` → `Theme.brandHighContrast` and
  HC player colours everywhere brand/player colour is used (toolbar tint, secondary
  button tint included).
- Touch targets ≥ 44pt: keys, chips, rows, both win actions, toolbar items (system).

**Out of scope, confirmed:** app icon (current kept); Live Activities, widgets, Duo
`ReservedRegion` fold handling (iOS 27.1 SDK follow-up per research §4).
