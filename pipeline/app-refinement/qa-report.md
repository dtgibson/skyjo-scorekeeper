# QA Report — App Refinement

**Date:** 2026-06-06
**Test Runner:** XCTest (xcodebuild, iPhone 17 simulator)
**Result:** PASSED

## Test Suite Results

67 tests passing (16 new), 0 failing. `** TEST SUCCEEDED **`
Suites: `GameSessionTests`, `GameSetupTests`, `SessionPersistenceTests`.

## New Tests Added

**Shared doubling rule (`GameSession.isDoubled`):** above-other, tied-with-other,
strictly-lowest, negative, zero, and an agreement test confirming the shared
function matches the engine's committed applied score (guards against the two
implementations drifting).

**Tie-break detection (`wasTieBroken`):** true when a tiebreaker decides a single
winner, false for co-winners, false for an outright single winner, false when the
game isn't over.

**Score-status thresholds (`scoreStatus`):** normal below 85, approaching 85–99,
bust at 100+.

**Schema version:** new snapshots carry `currentVersion`; a saved snapshot
round-trips its version; and — most importantly — a legacy JSON file with no
`schemaVersion` key still decodes (as nil) instead of failing, so an in-progress
game survives this upgrade.

## Change-Brief Criteria Verification

| Bundle | Result | Notes |
|---|---|---|
| 1 — Clarity (helper text, caption, chip removal, tie subtitle) | ✓ Pass | Verified in simulator |
| 2 — Quick fixes (stale-negative, danger colors, 44pt target, schema version, restore recheck) | ✓ Pass | Stale-negative + danger styling verified by user; schema version unit-tested |
| 3 — Entry-flow (live doubling preview) | ✓ Pass | Verified live in simulator |
| 4 — VoiceOver (announcements, running value, label fix, rule unification) | ✓ Pass | Build clean; doubling rule unification unit-tested |
| Translation pass (35 locales × 10 strings) | ✓ Pass | Placeholder integrity verified programmatically; catalog compiles |

## Regression Check

All pre-existing scoring, persistence, and setup tests still pass. The doubling
rule was refactored into a shared function with no behavior change (confirmed by
`testIsDoubledAgreesWithCommitRound` plus the existing doubling suite).

## Known Limitations

- The restore-time game-over recheck lives in `SkyjoScorekeeperApp.init` (an
  `App` struct) and isn't directly unit-tested; the underlying `isGameOver` it
  relies on is fully covered.
- VoiceOver announcements are verified by build and code review, not an automated
  accessibility test (no XCUITest target in this project).
