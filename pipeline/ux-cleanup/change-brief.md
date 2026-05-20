# Change Brief — UX Cleanup

## What is changing

Two small UI adjustments. First, the standalone minus/negative toggle button inside each score input row is removed; a single minus button is added to the keyboard toolbar (the bar that appears above the numpad), where it toggles the sign for whichever player's field is currently focused. The `isNegative` state moves from being local to each `ScoreInputRow` up to `ScoreEntrySheet` as `[UUID: Bool]`. Second, the green dot in the standings leader indicator is removed, leaving only the crown.fill SF Symbol. The crown alone communicates leadership without the redundancy.

## Why now

User feedback: the row-level minus button is confusing because it appears above the numpad rather than near it. The separate green dot next to the crown is redundant — the crown already serves as the non-color indicator.

## User-facing impact

Score entry: negative scores still work; the toggle just moves to the keyboard toolbar. Standings: the green dot disappears from the leader row; the crown remains.

## Decisions touched

- "Non-color leader indicator: A crown.fill SF Symbol supplements the green dot" (PRODUCT_CONTEXT.md) — this is partially reversed. The crown stays; the dot is removed. The crown alone provides both the color and non-color signal.
- Accessibility: the standings row combined label ("currently leading") is unchanged, so VoiceOver is unaffected.

## What done looks like

- On the score entry sheet, the minus/+ button appears in the keyboard toolbar, correctly toggled per the focused player, and negative scores commit correctly.
- No standalone minus button appears in any score input row.
- On the standings screen, only the crown appears next to the leader; no dot.
- All existing tests pass.
