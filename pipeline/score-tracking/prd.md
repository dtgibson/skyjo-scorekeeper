# PRD — Score Tracking

**Feature:** score-tracking
**Session:** 002
**Date:** 2026-05-09
**Stage:** 2 — The Planner

---

## Feature Overview

The score tracking screen is the active game view. It receives a confirmed player list from Game Setup, tracks round-by-round scores, enforces Skyjo's rules (including the doubling penalty), detects the game-ending condition, and presents the final standings. It also initiates the play-again flow back to Game Setup.

---

## User Stories

**US-01** — As a score keeper, I want to enter each player's score for the current round quickly, so that the group doesn't have to wait long between rounds.

**US-02** — As a player, I want to see everyone's running total at all times, so that I always know the current standings without doing mental math.

**US-03** — As a player, I want to know who is currently winning (lowest score), so that the competitive picture is always clear.

**US-04** — As a score keeper, I want the app to flag when the doubling rule applies and double the right player's score automatically, so that I don't have to remember or calculate it.

**US-05** — As a player, I want the app to detect when someone has crossed 100 and resolve the final round correctly, so that the game ends at the right time with the right winner.

**US-06** — As a player, I want to see a clear win screen with final standings, so that the end of the game feels conclusive.

**US-07** — As a player who wants to play again, I want to tap "New Game" and return to the setup screen with the same names already filled in, so that starting another game is frictionless.

**US-08** — As a score keeper who made a mistake, I want to be able to undo the most recent round's scores, so that I can correct errors without starting over.

---

## Functional Requirements

### Score Entry

**FR-01** — When the game starts, the app shall display the score tracking screen with all confirmed players visible and all scores at zero.

**FR-02** — The app shall present a round entry UI that shows one score input field per player.

**FR-03** — Score inputs shall use a number pad. Negative values shall be enterable (for rounds where a player scores below zero).

**FR-04** — The app shall not require scores to be entered in any particular order.

**FR-05** — The app shall display a "Confirm Round" control that commits the entered scores to all players' totals.

**FR-06** — The app shall not allow a round to be confirmed unless all player score fields are filled.

### Doubling Rule

**FR-07** — When the score keeper initiates round confirmation, the app shall ask: "Did anyone Skyjo this round?" with the option to select a player or indicate no one did.

**FR-08** — If a player is selected as having Skyjo'd, the app shall double that player's round score before adding it to their total — but only if that player does not have the lowest round score among all players.

**FR-09** — If the Skyjo'd player does have the lowest round score, no doubling occurs. The app shall handle this silently.

**FR-10** — The doubling calculation shall occur before totals are updated and before the game-end condition is checked.

### Running Totals and Standings

**FR-11** — After each confirmed round, the app shall display each player's updated cumulative total.

**FR-12** — The app shall visually highlight the player currently in the lead (lowest total). If two or more players are tied for lowest, all tied players shall be highlighted.

**FR-13** — The app shall display the current round number.

### Game End

**FR-14** — After confirming a round, the app shall check whether any player's cumulative total is 100 or greater.

**FR-15** — If the condition in FR-14 is met, the game ends. The app shall transition to the win screen.

**FR-16** — The win screen shall display all players ranked by final total (ascending). The player with the lowest total is the winner.

**FR-17** — Tiebreaker: if two or more players share the lowest total, the one with the lower score in the final round wins. If still tied, both are shown as co-winners.

**FR-18** — The win screen shall clearly call out the winner(s) by name.

**FR-19** — The win screen shall show each player's final total and their final round score.

### Play Again

**FR-20** — The win screen shall display a "New Game" button.

**FR-21** — Tapping "New Game" shall navigate to `GameSetupView` initialized with the same players from the just-completed game (using the existing `init(initialPlayers:)` on `GameSetupView`).

### Undo

**FR-22** — During an active game (not on the win screen), the app shall provide an undo control that removes the most recently confirmed round and reverts all player totals to their prior state.

**FR-23** — Undo shall only be available when at least one round has been confirmed.

**FR-24** — The app shall support only one level of undo (the most recent round only).

---

## Non-Functional Requirements

**NFR-01 — Compatibility:** iOS 17.0 and later.

**NFR-02 — Touch targets:** All tappable controls shall meet the 44×44pt minimum.

**NFR-03 — Performance:** Score confirmation (including doubling check and game-end check) shall complete within one animation frame.

**NFR-04 — Privacy:** No data leaves the device. All state is in-memory for the session.

**NFR-05 — Resilience:** If the app is backgrounded and foregrounded during an active game, in-progress state shall be preserved (standard iOS app lifecycle).

---

## Out of Scope

- Persisting game history between sessions
- Editing a previous round's scores (only undo of most recent round)
- More than one level of undo
- Exporting or sharing results
- Per-round score history breakdown view

---

## Acceptance Criteria

| ID | Scenario | Pass Condition |
|---|---|---|
| QA-01 | Fresh game start | Score screen shows all players at 0, round 1 |
| QA-02 | Score entry | Number pad appears; negative values accepted |
| QA-03 | Confirm blocked | Confirm button inactive until all fields filled |
| QA-04 | Doubling prompt | After filling scores, "Did anyone Skyjo?" prompt appears |
| QA-05 | Doubling applied | Skyjo'd player (not lowest score) has round score doubled |
| QA-06 | Doubling not applied | Skyjo'd player with lowest score: no doubling |
| QA-07 | No Skyjo | "No one" selection skips doubling and confirms normally |
| QA-08 | Running totals update | After confirmation, all totals reflect the new round |
| QA-09 | Leader highlighted | Player(s) with lowest total visually distinguished |
| QA-10 | Game end triggered | When any total reaches 100+, win screen appears |
| QA-11 | Winner correct | Player with lowest final total shown as winner |
| QA-12 | Tiebreaker | Among tied totals, lower final-round score wins |
| QA-13 | Win screen content | All players ranked with final total and final round score |
| QA-14 | New Game | Tapping "New Game" navigates to GameSetupView with same names |
| QA-15 | Undo available | After round 1, undo control is visible and active |
| QA-16 | Undo works | Tapping undo removes last round; totals revert |
| QA-17 | Undo unavailable | Before any round confirmed, undo is not shown or is disabled |
