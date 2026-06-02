# QA Report — Numpad Negative Toggle

**Date:** 2026-06-02
**Test Runner:** XCTest (xcodebuild, iPhone 17 simulator)
**Result:** PASSED

## Test Suite Results

51 tests passing, 0 failing. `** TEST SUCCEEDED **`

Suites: `GameSessionTests`, `GameSetupTests`, `SessionPersistenceTests`.
No scoring or persistence regressions — the engine behaves identically.

## Change-Brief Criteria Verification

| Criterion | Result | Notes |
|---|---|---|
| Tapping a player row focuses it; numpad inputs for that player | ✓ Pass | Confirmed in simulator |
| `+/−` button toggles sign for focused player | ✓ Pass | Confirmed — negative entry now straightforward |
| `⌫` removes the last digit | ✓ Pass | Wired to `dropLast()` on focused row |
| `−` prefix and red color appear when negative | ✓ Pass | Confirmed visually |
| No system keyboard appears on the sheet | ✓ Pass | `.numberPad` and keyboard toolbar removed entirely |
| Confirm button and Skyjo section remain reachable | ✓ Pass | Numpad sits above confirm; both visible |
| Focus indicator | ✓ Pass | Brand-colored ring around focused row (per user refinement) |

## Edge Cases Tested

- Sign handling moved from a signed string in `rawInputs` to digits + a
  separate `negativeInputs` flag. The `entries` computed property recombines
  them (`isNeg ? -value : value`). `GameSessionTests` exercise `commitRound`
  with the resulting `Int` values directly and all pass — the doubling rule,
  tiebreakers, and totals are unaffected.
- Digit cap at 3 characters prevents overflow input; leading-zero replacement
  ("0" → first digit) handled.

## Known Limitations

- The sheet's `entries` recombination logic is verified manually and indirectly
  (via the engine tests), not by a dedicated UI-layer unit test. The scoring
  engine itself remains fully covered.
