# PRD — Accessibility

**Feature:** accessibility
**Session:** 001
**Date:** 2026-05-16
**Stage:** 2 — The Planner
**Source:** strategic-brief.md (approved)

---

## Feature Overview

Adds comprehensive accessibility support across all four app screens so the app is usable by people with visual, motor, or cognitive disabilities. Covers VoiceOver narration, Dynamic Type scaling, Reduce Motion compliance, and non-color alternatives for all color-coded information.

---

## User Stories

**US-01** — As a VoiceOver user setting up a game, I want all player name fields, buttons, and avatars to be correctly labeled and navigable, so I can enter player names and start the game without sighted assistance.

**US-02** — As a VoiceOver user tracking scores, I want each standing row to read as a complete, meaningful unit ("Alice, 24 points, currently leading"), so I understand the game state without having to piece together separate elements.

**US-03** — As a VoiceOver user entering round scores, I want the score input rows, negative toggle, Skyjo chips, and Confirm button to have clear labels and states, so I can enter a complete round without assistance.

**US-04** — As a VoiceOver user on the win screen, I want each final ranking row to announce placement, name, score, and winner status together, so I understand the result fully.

**US-05** — As a user with a large text size preference, I want all text in the app to scale with my system setting, so I can read scores and names at my preferred size without anything being cut off.

**US-06** — As a user with Reduce Motion enabled, I want all animations to be disabled, so the app doesn't cause discomfort from motion.

**US-07** — As a Voice Control user, I want all buttons and interactive elements to have spoken names that match what I'd say to activate them, so I can control the app entirely by voice.

---

## Functional Requirements

### VoiceOver — GameSetupView

**FR-01** — Each player name text field shall have an accessibility label identifying it by position ("Player 1 name", "Player 2 name", etc.).

**FR-02** — Player avatar circles shall be hidden from the VoiceOver accessibility tree (they are decorative; the text field immediately adjacent provides the same identity information).

**FR-03** — Each Remove Player button shall have an accessibility label that includes the player's name ("Remove Alice").

**FR-04** — The "PLAYERS" section heading shall have the header accessibility trait.

**FR-05** — When a validation error state is active (blank fields highlighted in red), the error condition shall be conveyed to VoiceOver without relying solely on color.

### VoiceOver — ScoringView

**FR-06** — Each standing row shall be presented to VoiceOver as a single combined element whose label includes: player name, total score, and leader status if applicable (e.g., "Alice, 24 points, currently leading" or "Bob, 31 points").

**FR-07** — The leader dot indicator shall not appear as a separate VoiceOver element; its information shall be conveyed through the combined row label (FR-06).

**FR-08** — The "STANDINGS" section heading shall have the header accessibility trait.

**FR-09** — The Undo button shall include an accessibility hint describing its effect ("Removes the most recent round's scores").

**FR-10** — When the Undo button is disabled (no rounds have been played), its disabled state shall be conveyed to VoiceOver.

### VoiceOver — ScoreEntrySheet

**FR-11** — The drag handle at the top of the sheet shall be hidden from the VoiceOver accessibility tree (decorative).

**FR-12** — The "ROUND N SCORES" section heading shall have the header accessibility trait.

**FR-13** — Each score input row shall be presented to VoiceOver as a single combined element whose label includes the player name; the score field within the row shall have an accessibility label ("Score for Alice").

**FR-14** — The negative score toggle button shall have an accessibility label ("Negative score") and an accessibility value reflecting its current state ("on" when active, "off" when inactive).

**FR-15** — When a doubling preview appears next to a player's name (e.g., "×2 → 16"), this information shall be conveyed to VoiceOver as part of that row's narration.

**FR-16** — The "WHO ENDED THE ROUND?" section heading shall have the header accessibility trait.

**FR-17** — Each Skyjo chip shall have an accessibility label that clearly describes the action ("Alice called Skyjo" for player chips; "Nobody called Skyjo" for the Skip chip).

**FR-18** — Each Skyjo chip shall convey its selected state to VoiceOver (selected / not selected).

**FR-19** — The Confirm button shall convey its disabled state to VoiceOver when not all scores have been entered or the Skyjo question has not been answered.

### VoiceOver — WinView

**FR-20** — Each final ranking row shall be presented to VoiceOver as a single combined element whose label includes: placement, player name, total score, and winner status if applicable (e.g., "First place: Alice, 45 points, winner" or "Second place: Bob, 67 points").

**FR-21** — Medal emojis shall not appear as separate VoiceOver elements; placement information shall be conveyed through the combined row label (FR-20).

**FR-22** — The winner trophy or handshake emoji in the hero section shall have an accessibility label ("Winner" or "It's a tie") or be hidden from VoiceOver if the headline immediately below conveys the same information.

**FR-23** — The "FINAL STANDINGS" section heading shall have the header accessibility trait.

### Dynamic Type

**FR-24** — All text throughout the app shall use Dynamic Type semantic text styles rather than hardcoded point sizes, preserving the SF Rounded typeface.

**FR-25** — At all Dynamic Type sizes, including the five largest accessibility sizes (AX1–AX5), no text shall be truncated or clipped within its intended display area.

**FR-26** — At all Dynamic Type sizes, all interactive elements (buttons, text fields, chips) shall remain fully tappable and correctly labeled.

**FR-27** — Row heights that are currently fixed shall expand to accommodate larger text rather than clipping content.

### Reduce Motion

**FR-28** — When the system Reduce Motion accessibility setting is enabled, all animations throughout the app shall be disabled and state changes shall occur immediately without transition.

### Non-Color Information

**FR-29** — The leader status indicator in ScoringView currently uses a green dot as the sole visual indicator. When VoiceOver is active, leader status shall be conveyed through the row's combined label (FR-06), not the dot alone.

**FR-30** — The winner row highlight in WinView currently uses a color tint as the sole visual indicator. Winner status shall be conveyed through the row's combined label (FR-20), not the tint alone.

**FR-34** — The leader indicator in ScoringView shall include a non-color visual element (a symbol such as a star or crown) alongside the green dot, so that the leading player is identifiable by sighted users who cannot distinguish colors, without requiring VoiceOver.

### Section Headers

**FR-31** — All uppercase section labels throughout the app ("PLAYERS", "STANDINGS", "FINAL STANDINGS", "ROUND N SCORES", "WHO ENDED THE ROUND?") shall have the header accessibility trait so VoiceOver users can navigate between sections.

### Increase Contrast

**FR-32** — When the system Increase Contrast accessibility setting is enabled, all custom color values — `Theme.brand` and all eight player palette colors — shall provide higher-contrast variants that maintain a minimum 4.5:1 contrast ratio for normal-weight text against their paired text color (WCAG AA).

**FR-33** — Each player avatar color shall be individually verified to meet the 4.5:1 WCAG AA contrast ratio with white text at standard contrast. Any colors that do not meet this threshold shall be adjusted to the nearest compliant value.

---

## Non-Functional Requirements

**NFR-01 — Compatibility:** All accessibility features shall function correctly on iOS 17.0 and above, matching the app's minimum deployment target.

**NFR-02 — No regression:** No visual change shall be observable on any screen as a result of Dynamic Type changes at the system default text size. At default size, the app shall look identical to its pre-feature state.

**NFR-03 — VoiceOver completeness:** Every interactive element on every screen shall be reachable and operable by VoiceOver swipe navigation alone.

**NFR-04 — Voice Control:** All interactive elements shall be activatable by Voice Control using their visible label text or their accessibility label where no visible text exists.

---

## Out of Scope

- RTL (right-to-left) layout support
- Custom Switch Control navigation beyond SwiftUI's automatic support
- Braille display optimization
- watchOS or other platform accessibility
- Changes to game logic, models, or navigation
- Pointer (trackpad/mouse) accessibility
- Any visual design changes at the default text size

---

## Open Questions

None — all decisions are resolved in this document.

---

## Success Metrics

| ID | What's Being Verified | Pass Condition |
|---|---|---|
| QA-01 | VoiceOver — GameSetupView player fields | Each text field announces "Player N name, text field" |
| QA-02 | VoiceOver — GameSetupView remove buttons | Remove button announces "Remove [name], button" |
| QA-03 | VoiceOver — ScoringView standing rows | Each row announces name, score, and leader status as one element |
| QA-04 | VoiceOver — ScoringView leader dot | Leader dot does not appear as a separate VoiceOver stop |
| QA-05 | VoiceOver — ScoringView Undo button | Undo announces hint; disabled state announced when no rounds played |
| QA-06 | VoiceOver — ScoreEntrySheet drag handle | Drag handle is skipped by VoiceOver |
| QA-07 | VoiceOver — ScoreEntrySheet negative toggle | Toggle announces "Negative score, on/off" |
| QA-08 | VoiceOver — ScoreEntrySheet Skyjo chips | Each chip announces "[name] called Skyjo" or "Nobody called Skyjo" with selected state |
| QA-09 | VoiceOver — ScoreEntrySheet Confirm button | Confirm announces disabled state when not all scores entered |
| QA-10 | VoiceOver — WinView ranking rows | Each row announces placement, name, score, and winner status as one element |
| QA-11 | VoiceOver — section headers | "STANDINGS", "PLAYERS", etc. have header trait and appear in VoiceOver rotor |
| QA-12 | Dynamic Type — default size | App is pixel-identical to pre-feature state at system default text size |
| QA-13 | Dynamic Type — AX3 size | All text visible and untruncated at AX3 accessibility text size on all four screens |
| QA-14 | Dynamic Type — AX5 size | All text visible and untruncated at AX5 (largest) accessibility text size on all four screens |
| QA-15 | Reduce Motion — animations disabled | With Reduce Motion on, no animation plays anywhere in the app |
| QA-16 | Non-color — leader indicator | Leader status conveyed in VoiceOver without green dot |
| QA-17 | Non-color — winner row | Winner status conveyed in VoiceOver without color tint |
| QA-18 | Voice Control — all screens | All interactive elements activatable by speaking their visible or accessibility label |
| QA-19 | Full VoiceOver game | A VoiceOver user can complete setup → scoring → win without sighted assistance |
| QA-20 | Increase Contrast — avatars and button | With Increase Contrast enabled, all player avatars and primary button remain visually distinct and readable |
| QA-21 | Increase Contrast — brand color | With Increase Contrast enabled, brand color meets 4.5:1 contrast against its background on all screens |
| QA-22 | Differentiate Without Color — leader indicator | Leading player is identifiable by a sighted color-blind user without relying on the green dot color |
