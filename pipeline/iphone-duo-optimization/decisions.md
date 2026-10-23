# Decisions — iPhone Duo Optimization

Logged by The Designer at the Improve-lane design pass (2026-10-22). The user approved the
mockup exactly as shown; these are the deliberate deviations from the shipped screens and
from the iOS 27 refinement spec, so none of them is silent drift.

## Design system status

No `pipeline/design-system.md` exists yet. This pass was designed within `brand.md` and
`pipeline/ios-27-platform-readiness/design-refinement.md` (the previous refinement of the
same screens), extending them without reinventing anything: SF Rounded, `Theme.brand`
indigo as the single accent, position-indexed player colours, 14pt cards, 16pt primary
button, `Theme.contentMaxWidth` 600pt. Consolidating those two sources into
`pipeline/design-system.md` is recommended after this run, but is outside this task.

## D1 — Scoreboard title re-homed on the divided layout

**What:** When the window reports a vertical fold, `ScoringView` sets
`.navigationTitle("")` and renders "Round N" as the heading of the right page (34pt,
`.heavy`, `.rounded`, brand colour / HC variant, tracking −0.8, `.isHeader`), with the
existing rule caption beneath it. Everywhere else the inline navigation title stays.

**Why:** The system toolbar pushes End Game and Undo to the side edges, one per page, but
an inline title is centred, which lands it on the spine where it reads as two half-words.
Moving the same string to the action page keeps it readable and gives the right page its
heading. No new string: `"Round %lld"` is reused. The Engineer verifies the system's
actual title placement in the Duo simulator before blanking it.

## D2 — Setup title moves to the right page beside Start Game

**What:** On the divided layout the "Skyjo Scorekeeper" title and "Who's playing today?"
sit at the top of the right page, with Start Game and the ready note pinned at its bottom;
the PLAYERS list takes the whole left page. The three-second long-press Easter egg stays on
the title. Tall, short and tabletop layouts are unchanged.

**Why:** The user chose the book arrangement (cover and call to action on one page, the
roster on the other) over keeping the title above the list. It gives the list the full
page height and keeps the title's long-press target off the fold.

## D3 — Easter egg card gains the 600pt cap and an origin-aware scale

**What:** `EasterEggOverlay`'s card is capped at `Theme.contentMaxWidth` (width =
min(600, container − 48)); on a vertical fold it centres within the right page, on a
horizontal fold within the upper page. Its entrance becomes scale 0.9 → 1 + opacity,
ease-out, 200ms, anchored at the title it came from; Reduce Motion crossfades only.

**Why:** Today the card ignores the 600pt cap (a 903pt card on the open display) and
scales from the screen centre with ease-in-out, which puts Close on the crease and breaks
the "single width ceiling" convention in CLAUDE.md. The cap and the origin-aware ease-out
entrance follow the design doctrine (origin-aware, ease-out, <300ms) without changing the
card's look.

## Engineer notes (Stage 3, 2026-10-22)

**How the open pose was checked.** The Mac's screen was locked for the whole session, so
Device Hub (the only pose control in Xcode 27.1; `simctl`/`devicectl` have none) could not be
driven, and the Duo simulator stayed closed. The open and tabletop layouts were checked on the
iPhone Duo simulator (iOS 27.1) with the app in a 951 × 669pt (open) or 669 × 951pt (tabletop)
window (`devicectl device appResize`). A temporary, since-removed fake 24pt fold sat at the
window's centre, where the real fold is. Screenshots are in `screenshots/` (`*-simfold-*`,
band drawn in red). The real fold on a real pose still needs a look in Device Hub.

**D1 applied.** With no fold to avoid, the system centres the inline "Round 4" exactly on the
fold line (`screenshots/duo-open-simfold-scoreboard-before-D1.png`). The iOS 27.1 UIKit
shared cache has fold-avoidance code only for split views, the Home Screen, FaceTime,
PosterBoard and onboarding, and none for navigation bars or sheets. So the title would land on
the fold, and D1 was applied as mocked.

**Entry sheet fallback built (E1).** In the open window the system shows the entry sheet as a
centred ~650pt card. It ignores the fitted 720pt size there, and the 8/5/2/0 keys and Confirm
sat on the fold. In tabletop the "who ended" chips sat on it. Instead of resizing the
presentation (the system overrides it), the sheet reads the fold that crosses it and makes it
its divider. Rows go left / controls right for a vertical fold; rows go above / chips, keypad
and Confirm below for a horizontal one. If the system ever keeps the sheet on one page, no
fold crosses it and the shipped layouts apply unchanged.

**Camera regions (E2).** The resizable window reported a camera region reaching 46pt into the
content (below the safe area), at the top right. A page now starts below any camera region in
its top half, not only ones touching its top edge. On the closed display the camera regions
sit in the safe area and nothing moves.

**Reduce Motion on the Easter egg (E3).** D3 says Reduce Motion "crossfades only". CLAUDE.md
requires every animation to be `reduceMotion ? nil : …`, so with Reduce Motion the card
appears and disappears instantly, as it did before this build.

**The fold is read even while inactive (E4).** `ReservedRegion` marks regions active or
inactive, and SpringBoard's hinge model has an "activate fold avoidance" angle range, so the
fold may be reported inactive when the phone lies flat. Reading only active folds would snap the
open display back to one centred column (Start and Enter on the crease) whenever the hinge
crossed that range. Folds are therefore read with `.includeInactive`; camera regions stay
active-only.
