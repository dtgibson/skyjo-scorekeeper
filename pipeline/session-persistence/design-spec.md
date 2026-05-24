# Design Spec — Session Persistence

## Visual Direction

This feature is invisible by design — no new screens, no new UI elements. The visual language is entirely unchanged from the existing app. The "design" is the absence of disruption: a user who returns to the app mid-game sees their scoring view exactly as they left it, indistinguishable from a live game.

## Screens / Views

### Restored Scoring View (ScoringView)

Identical to a live in-progress game at the same round number. No visual differences from the non-restored state.

**Key design decisions:**
- No "session restored" banner, toast, or indicator of any kind
- No loading state or transition animation on restore — the view appears immediately
- Round number in the nav bar reflects the correct next round (committed rounds + 1)
- Undo button is enabled if rounds exist, disabled if rounds list is empty
- Standings card shows correct cumulative totals and leader highlight

### No New Screens

There are no new screens, sheets, alerts, or overlays introduced by this feature. The feature's entire surface is the existing ScoringView — restored rather than freshly created.

## Component Usage

No new components. All existing components (nav bar, standings card, StandingRowView, enter button) are reused as-is.

## Design Tokens Applied

Unchanged from existing app. All token values from `brand.md` apply without modification.

## Interaction Notes

- **On app launch with saved state:** Route directly to ScoringView. No animation or transition different from the normal setup → game transition.
- **On app launch without saved state:** Normal flow to setup screen. Unchanged.
- **Save triggers are silent:** No visual feedback when state is written to disk after commitRound or undoLastRound.
- **Clear triggers are silent:** No visual feedback when saved state is deleted.

## Content Notes

No new copy or localization strings required. All UI copy is existing.
The one implicit "content" decision: the absence of a "game restored" message is intentional and permanent — future iterations should not add one unless there is a strong user research reason to do so.
