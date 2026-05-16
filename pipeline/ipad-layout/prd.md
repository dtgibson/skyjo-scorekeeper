# PRD — iPad Layout

**Feature:** ipad-layout
**Session:** 001
**Date:** 2026-05-15
**Stage:** 2 — The Planner
**Source:** strategic-brief.md (approved)

---

## Feature Overview

Adapts all four app screens (game setup, scoring, score entry sheet, win) to display properly on iPad by constraining content to a maximum width and centering it on large screens. iPhone layout is unchanged. No new views, models, or navigation changes are required.

---

## User Stories

**US-01** — As an iPad user setting up a game, I want the player name fields and start button to be properly sized and centered, so the screen doesn't look like an iPhone app stretched to fit.

**US-02** — As an iPad user tracking scores mid-game, I want the standings card and nav bar to be width-constrained and centered, so scores are easy to read and controls are in expected positions.

**US-03** — As an iPad user entering round scores, I want the score entry sheet content to be contained and readable, so I'm not using a narrow form floating in a large sheet.

**US-04** — As an iPad user viewing the win screen, I want the winner announcement and final standings to be centered and well-proportioned, so the end of the game feels as polished as the rest of it.

**US-05** — As an iPhone user, I want none of my existing layout to change, so the iPad work doesn't introduce regressions on the device I use.

---

## Functional Requirements

### Shared layout constraint

**FR-01** — A single `contentMaxWidth` constant shall be defined in `Theme.swift` with a value of 600pt. All four views shall reference this constant — it shall not be hardcoded per-view.

**FR-02** — On any screen whose available width exceeds `contentMaxWidth`, primary content shall be centered horizontally with equal leading and trailing padding outside the content boundary.

**FR-03** — On any screen whose available width is at or below `contentMaxWidth`, layout shall behave identically to the current iPhone layout. No visual change shall occur on iPhone.

### GameSetupView

**FR-04** — The player list, "Add Player" button, and "Start Game" button shall be contained within a region no wider than `contentMaxWidth`, centered on the screen.

### ScoringView

**FR-05** — The standings card shall be contained within a region no wider than `contentMaxWidth`, centered on the screen.

**FR-06** — The nav bar (End Game / Round N / Undo) shall be horizontally constrained to match the content width, so controls do not spread to the full edges of a large screen.

**FR-07** — The "Enter Round N Scores" primary button shall be contained within a region no wider than `contentMaxWidth`, centered on the screen.

### ScoreEntrySheet

**FR-08** — The score entry sheet's scroll content (player rows and Skyjo question section) shall be contained within a region no wider than `contentMaxWidth`, centered within the sheet.

**FR-09** — The "Confirm" button at the bottom of the sheet shall be contained within the same width constraint.

### WinView

**FR-10** — The winner hero section and final standings list shall be contained within a region no wider than `contentMaxWidth`, centered on the screen.

**FR-11** — The "New Game — Same Players" and "Start Fresh" action buttons shall be contained within the same width constraint.

---

## Non-Functional Requirements

**NFR-01 — Compatibility:** The layout shall display correctly on iPad in both portrait and landscape orientations at all iPad sizes (11-inch and 13-inch as minimum targets).

**NFR-02 — Regression:** No visual change shall be observable on any iPhone screen size as a result of this feature.

**NFR-03 — Consistency:** The `contentMaxWidth` constant shall be the single source of truth. If the value needs to change, it changes in one place.

---

## Out of Scope

- iPad Split View, Slide Over, or Stage Manager support
- Pointer (trackpad/mouse) or hardware keyboard support
- Drag-and-drop interactions
- Multi-window support
- iPad-only UI patterns (sidebars, popovers, master-detail)
- Any change to models, navigation, or game logic

---

## Open Questions

None — all decisions are resolved in this document.

---

## Success Metrics

| ID | What's Being Verified | Pass Condition |
|---|---|---|
| QA-01 | `contentMaxWidth` constant exists in Theme.swift | `Theme.contentMaxWidth` compiles and equals 600 |
| QA-02 | iPhone layout unchanged — GameSetupView | On iPhone 16 simulator, GameSetupView is pixel-identical to pre-feature behavior |
| QA-03 | iPhone layout unchanged — ScoringView | On iPhone 16 simulator, ScoringView is pixel-identical to pre-feature behavior |
| QA-04 | iPhone layout unchanged — ScoreEntrySheet | On iPhone 16 simulator, ScoreEntrySheet is pixel-identical to pre-feature behavior |
| QA-05 | iPhone layout unchanged — WinView | On iPhone 16 simulator, WinView is pixel-identical to pre-feature behavior |
| QA-06 | iPad portrait — GameSetupView centered | On iPad 13-inch simulator (portrait), player list is visibly centered with equal horizontal margins outside a width-constrained column |
| QA-07 | iPad portrait — ScoringView centered | On iPad 13-inch simulator (portrait), standings card and nav bar are centered and width-constrained |
| QA-08 | iPad portrait — ScoreEntrySheet centered | On iPad 13-inch simulator (portrait), score entry rows and confirm button are centered and width-constrained |
| QA-09 | iPad portrait — WinView centered | On iPad 13-inch simulator (portrait), winner section and standings are centered and width-constrained |
| QA-10 | iPad landscape — all screens | All four screens pass QA-06 through QA-09 equivalents in landscape orientation |
| QA-11 | Single constant governs all views | Changing `Theme.contentMaxWidth` to 500 causes all four views to narrow together |
