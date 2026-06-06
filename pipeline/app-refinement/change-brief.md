# Change Brief — App Refinement

## What is changing

A batch of refinements from the 2026-06-05 comprehensive review (see
`findings.md`), grouped into four bundles, implemented and reviewed one at a
time:

1. **New-player clarity** — inline microcopy explaining who-ended-the-round,
   why a score doubles, and the first-to-100-loses ceiling; rename the "Skip"
   chip to "No one"; explain tie-broken wins on the win screen.
2. **Quick fixes & polish** — fix the stale-negative numpad bug; add a
   non-color near-100 / over-100 cue; enlarge the remove-player touch target to
   44pt; add a `schemaVersion` to the saved-game snapshot; re-check game-over on
   restore.
3. **Entry-flow speed** — treat an untouched score row as 0 (gate Confirm on the
   Skyjo answer only) / fast-zero; auto-advance focus between players; show the
   doubling preview live during entry.
4. **VoiceOver depth** — announce round-committed / undo / winner; give the
   numpad spoken feedback and a running value; replace the fragile "→"-parsing
   a11y label by computing the doubled value directly. Unify the doubling rule
   into one tested function (supports this and removes duplication).

## Why now

The app is correct and stable, so this is the right moment to refine clarity,
accessibility, and input flow. Most items are small and directly serve the
product goals: simple, intuitive, accessible, lightweight.

## User-facing impact

Additive microcopy and clearer labels; a fixed input bug; a non-color danger
cue; faster score entry; richer VoiceOver feedback. No new screens, no new data
model beyond a forward-compat version tag. Out of scope (feature-sized, cut for
lightweight): per-round history/edit, and a "finish game now → standings" exit.

## Decisions touched

- **Numpad Negative Toggle (2026-06-02)** — extended, not reversed: the stale-
  sign bug fix and live doubling preview build on the new numpad.
- A new decision will be logged for treating an empty score row as 0 (changes
  the Confirm gate contract) if that approach is chosen.

## What done looks like

- Each bundle implemented, verified in the simulator, and confirmed before the
  next begins.
- Full test suite stays green; new logic (unified doubling rule, empty-as-0)
  gets unit tests.
- No regressions to scoring, persistence, or existing accessibility support.
