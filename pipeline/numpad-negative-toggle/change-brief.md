# Change Brief — Numpad Negative Toggle

## What is changing

The negative-score toggle is moving from the keyboard toolbar to a custom
numpad built into the score entry sheet. The system `.numberPad` keyboard
is replaced by a custom always-visible numpad at the bottom of the sheet,
with a `+/−` button in the lower-left position (matching the iPhone
calculator layout). Player rows become tap-to-focus targets; the numpad
handles all digit input and the sign toggle for the focused player. The
keyboard toolbar is removed.

## Why now

The toolbar button is not discoverable. Users who have never seen it miss
it and assume negative scores can't be entered. A calculator-style numpad
matches the mental model users already have from the iOS Calculator app.

## User-facing impact

The system keyboard no longer appears on the score entry sheet. The numpad
is always visible. The `+/−` button is in the lower-left of the numpad.
The `−` prefix and red text on negative scores remain unchanged. Tab-order
(Next / Done) via the toolbar is replaced by tapping rows directly.

## Decisions touched

- **"Negative score toggle lives in the keyboard toolbar, not the input
  row"** (DECISIONS.md) — directly reversed. The toggle moves onto the
  numpad itself.

## What done looks like

- Tapping a player row focuses it; the numpad inputs digits for that player
- `+/−` button toggles the sign for the focused player
- `⌫` removes the last digit
- Score displays update in real time; `−` prefix and red color appear when negative
- No system keyboard appears; confirm button and Skyjo section remain reachable
- All 12 SessionPersistenceTests and existing test suites still pass
