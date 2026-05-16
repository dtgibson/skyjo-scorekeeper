# Design Spec — Score Tracking

**Feature:** score-tracking
**Date:** 2026-05-09
**Stage:** 4 — The Designer

---

## Screen Architecture

Three distinct screens, all sharing the same brand tokens from `Theme.swift`.

---

## Screen 1: Active Game (Scoreboard)

**Layout:** Full-screen, systemGroupedBackground (#F2F2F7)

**Navigation bar:**
- Center: "Round N" (SF Rounded, 17pt semibold)
- Trailing: "↩ Undo" (brand color, 15pt, hidden/disabled before round 1)
- No back button — this screen owns the session

**Standings card:**
- White card, 14pt corner radius, subtle shadow
- One row per player (62pt tall), dividers between
- Row contents: avatar circle (36pt, Okabe-Ito position color) + name (17pt) + optional leader dot (8pt green circle) + total (22pt bold)
- Leader row: rgba(52,199,89,0.07) background tint; green dot visible only for lowest-total player(s)
- Players sorted by total ascending after round 1; fixed order on round 0

**Primary button:**
- "Enter Round N Scores" — full-width, 58pt, 16pt radius, brand fill
- Pinned to bottom above safe area

---

## Screen 2: Score Entry Sheet

**Presentation:** `.sheet` modal sliding up from bottom, detent at ~85% screen height. Background dims to rgba(0,0,0,0.35) with 1pt blur.

**Sheet contents (top to bottom):**

1. Drag handle (36×5pt, #D1D1D6, centered)
2. Title: "Round N Scores" (20pt bold)
3. Score input card (white, 14pt radius):
   - One row per player (56pt tall)
   - Row: avatar (30pt) + name (17pt) + ± toggle button (30pt circle, #E5E5EA background, brand icon) + score display (22pt bold, right-aligned)
   - Empty state: "—" in #C7C7CC
   - Negative values: displayed in #30B0C7 (teal)
   - **Skyjo'd player row:** rgba(55,48,163,0.04) background tint; score display shows entered value (22pt) with "×2 → [doubled]" in brand color (11pt semibold) directly below — only shown when this player is selected in the Skyjo selector and the doubling rule will apply
4. "Who Skyjo'd this round?" section:
   - Label: 12pt uppercase, #6B6B6B, letter-spacing 0.6pt
   - Player chips: avatar color dot (10pt) + name, pill shape, 1.5pt border
   - Selected state: brand-color border + rgba(55,48,163,0.08) fill + brand text
   - "No one" chip: no dot, same styling
   - One selection required before Confirm is enabled
5. "Confirm Round N" primary button — disabled (0.3 opacity) until all score fields filled AND Skyjo selection made

---

## Screen 3: Win Screen

**Hero section:** Full-width, linear-gradient(155deg, #3730A3, #5B52D4), white text
- Trophy emoji (60pt)
- Winner name (32pt, weight 800, letter-spacing -0.5pt)
- Subtitle: "Game over · N rounds" (15pt, 75% opacity)

**Final standings card:** White card, 14pt radius
- One row per player, ranked ascending by final total
- Row: medal emoji or rank number + avatar (36pt) + name column (name + "N final round" detail) + final total
- Winner row: rgba(52,199,89,0.07) tint
- Totals ≥ 100: displayed in #FF3B30 (system red)
- Final round detail line shows actual applied score (e.g. "+24 final round (doubled)")

**Actions:**
- "New Game with Same Players" — primary button, brand fill
- "Start Fresh" — text link below, brand color, navigates to GameSetupView with no pre-populated players

---

## Tokens

| Token | Value |
|---|---|
| Brand | #3730A3 |
| Background | #F2F2F7 |
| Card | #FFFFFF |
| Leader tint | rgba(52,199,89,0.07) |
| Negative score | #30B0C7 |
| Over-100 score | #FF3B30 |
| Doubling preview | #3730A3, 11pt semibold |
| Sheet overlay | rgba(0,0,0,0.35) |

---

## Behavior Notes

- Score entry uses `.numberPad` keyboard. The ± button toggles the entered value between positive and negative.
- The doubling preview ("×2 → N") appears immediately when a player is selected in the Skyjo chip selector, before Confirm is tapped.
- If the Skyjo'd player has the lowest round score, no preview is shown (doubling won't apply) — this is handled silently per the PRD.
- Confirm button activates only when: all score fields have a value AND the Skyjo selector has a selection.
