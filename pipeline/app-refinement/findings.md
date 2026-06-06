# Comprehensive App Review — Skyjo Scorekeeper

**Date:** 2026-06-05
**Lens:** Simplicity · Intuitiveness · Accessibility · Lightweight · Functional
**Method:** Four parallel reviewers (accessibility, UX, code quality, functional robustness) across all 17 source files (~1,600 LOC).

## Bottom line

The app is in good shape. No high-severity correctness bugs, no data-loss bugs. The scoring engine, doubling rule, tiebreakers, game-over detection, undo, and persistence are correct and well-tested. The existing accessibility foundation (semantic fonts, color-blind-safe palette with high-contrast variant, Reduce Motion, Dynamic Type, compound-row labels) is genuinely strong.

The opportunities cluster into: **explaining the rules to new players**, **a few real-but-contained bugs**, **deeper VoiceOver feedback**, **entry-flow friction**, and **invisible code-leanness wins**.

---

## Tier 1 — Quick wins (high value, small effort)

| # | Finding | Why it matters | Effort |
|---|---|---|---|
| 1 | **The app never explains its own rules.** "WHO ENDED THE ROUND?", the "×2" doubling badge, and the first-to-100-loses ceiling are never explained. A new player can't build a correct mental model. | Directly undercuts "simple & intuitive" for anyone new to Skyjo. | S (inline microcopy) |
| 2 | **"Skip" chip is mislabeled.** The chip visibly reads "Skip" but means "Nobody ended the round" (its VoiceOver label already says "Nobody"). "Skip" reads as "skip this question," silently disabling the doubling rule. | Visible text contradicts its own function and the a11y label. | S (rename) |
| 3 | **Stale negative sign after backspace (real bug).** Toggle negative → type → backspace to empty leaves the red "−" over "0"; the next digit typed is silently negative. | Reproducible wrong-input bug in the brand-new numpad. | S |
| 4 | **≥100 and near-100 rely on red color alone.** Totals turn red only at 100 (after the game's already over). No "danger zone" cue as a player approaches the ceiling, and color-only fails for color-blind users. | Misses the game's tension moment; color-only signal. | S |
| 5 | **Remove-button touch target is ~24pt** (under the 44pt minimum) in player setup. | Motor-accessibility miss. | S |
| 6 | **Redundant "Round N" labels** — the round number is restated on the scoreboard button, sheet header, and confirm button. | Minor visual noise; "Confirm" alone is clearer. | S |

---

## Tier 2 — Real bugs & robustness

| # | Finding | Severity | Effort |
|---|---|---|---|
| 7 | **VoiceOver label re-derives data from a display string.** The doubling a11y label parses the visible "×2 → N" badge by splitting on "→" instead of using the known `raw*2`. Works today (the badge is a hardcoded literal), but it's fragile and breaks the moment that string is ever localized. | Medium (latent) | S |
| 8 | **No schema version in the saved game.** `GameSessionSnapshot` has no version field. A future model change makes old `active-game.json` files fail to decode, silently discarding an in-progress game on upgrade. | Medium (forward-compat) | S |
| 9 | **Restore doesn't re-check game-over.** On launch the app trusts the saved file is in-progress. Defensive only (not reachable via UI today), but one line of insurance routes a ≥100 restored state to setup. | Low (defensive) | S |
| 10 | **Mid-entry input lost if app is killed before commit.** Typed-but-uncommitted scores live only in view state. Arguably acceptable for a scorekeeper; worth a deliberate decision (document vs. persist a draft). | Low | S (document) / M (persist) |

---

## Tier 3 — Deeper accessibility (VoiceOver feedback)

| # | Finding | Severity | Effort |
|---|---|---|---|
| 11 | **No VoiceOver announcements after state changes.** Committing a round, undoing, and reaching the win screen all happen silently — a blind user gets no confirmation of what changed or who won. Biggest remaining a11y gap. | High (for VO users) | M |
| 12 | **Numpad gives no spoken feedback / running value.** Digit keys are bare "1".."9"; the entered score is `accessibilityHidden` with no `accessibilityValue`, so a VO user can't hear what they've typed. Makes blind score entry very hard. | High (for VO users) | M |
| 13 | **Focused-row indicator is color-only** (brand ring) with no `.isSelected` trait. | Medium | S |
| 14 | **Custom-tracked large titles** (setup logo, win headline) use fixed negative letter-spacing that doesn't scale; long names at AX sizes risk clipping. Add `minimumScaleFactor`. | Medium | S |

---

## Tier 4 — Entry-flow friction (touches input logic)

| # | Finding | Why | Effort |
|---|---|---|---|
| 15 | **Confirm is blocked until every player has a typed value**, even though empty rows already display "0". Forces N taps per round for a player who scored 0. Consider treating empty as 0 (gate only on the Skyjo answer) or a one-tap zero. | Removes taps every round | M |
| 16 | **No auto-advance between players.** The shared numpad only moves focus on a manual row tap; entering 8 players means 8 extra focus taps. A "Next" affordance or auto-advance restores calculator-like flow. | Removes taps | M |
| 17 | **Doubling preview only appears once all scores are entered**, so the rule's main teaching moment arrives too late to guide entry (and looks like a glitch popping in). | Clarity of the rule | S–M |

---

## Tier 5 — Code leanness (invisible to users)

| # | Finding | Why | Effort |
|---|---|---|---|
| 18 | **Doubling rule implemented twice** (engine `commitRound` + sheet preview), plus a third copy of "min of others." They agree today but must be hand-kept in sync. Extract one pure function; unblocks unit-testing the preview. | Leaner, safer | S |
| 19 | **Avatar + high-contrast-brand resolution duplicated** across ~5 avatar blocks and ~7 brand sites. Extract a `PlayerAvatar` view and a single HC-brand helper. | Removes duplication | M |
| 20 | **`standings` recomputed many times per render.** Non-memoized; `isGameOver`/`winners` each recompute it, and WinView derives it a dozen+ times per render. Capture once / cache on `rounds` change. | Leaner | S–M |
| 21 | **Setup list uses O(n) `firstIndex` lookups** in the loop where `enumerated()` (used by the other two lists) would give the index for free; player-count constants live only on `GameState`. | Minor consistency | S |

Note: **`GameState` is NOT dead code** — it's live (setup view + tests). No dead code was found.

---

## Tier 6 — Capability adds (weigh against "lightweight")

These add functionality and surface area. Flagged explicitly so they're chosen deliberately, not by reflex.

| # | Finding | Note | Effort |
|---|---|---|---|
| 22 | **No way to view or correct a past round** — only "Undo last" exists, which destroys every later round. A single early typo is effectively uncorrectable. A read-only per-round history is the lighter middle ground; editable is the full fix. | Highest-requested-feeling gap, but adds UI | M (read-only) / L (editable) |
| 23 | **End Game is a destructive dead-end.** The only early exit discards everything; there's no "finish now and show standings." WinView already handles arbitrary standings, so reuse is high. Also rename the ambiguous "✕ End Game". | Adds an early-finish path | M |

---

## Low-priority polish

- Tie-broken wins aren't explained on the win screen ("Tie broken by lowest final round"). — S
- Duplicate player names allowed with no warning (distinct IDs, so not a bug; usability nuisance). — S
- "Start Fresh" on the win screen is low-contrast plain text vs. the prominent "New Game" button. — S

---

## Confirmed solid (not problems)

Reduce Motion wrapping everywhere; high-contrast palette correctly threaded through every color site; decorative elements hidden from VoiceOver; compound rows collapsed with combined labels; `minHeight` used consistently; CLDR plurals handled; doubling/game-over/tiebreaker/undo/corrupt-file paths all correct and tested; atomic writes prevent torn save files.
