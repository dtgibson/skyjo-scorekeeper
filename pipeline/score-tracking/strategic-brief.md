# Strategic Brief — Score Tracking

**Feature:** Score Tracking
**Project:** Skyjo Scorekeeper
**Date:** 2026-05-09

---

## What This Feature Does

Score tracking is the active game screen. Players use it from the moment the game starts until a winner is declared. It accepts one round of scores at a time, maintains running totals for each player, applies the game's special rules, and ends the game when the winning condition is met.

---

## Skyjo Rules This Feature Must Understand

**Round scoring:** After each round, every player's score for that round is added to their running total. Scores per round can be negative (card values in Skyjo run from -2 to 12).

**Game end trigger:** The game ends at the conclusion of a round in which at least one player's cumulative total reaches or exceeds **100 points**.

**The Skyjo penalty (doubling rule):** The player who triggers the end of a round by flipping their last card has their score **doubled for that round** if they do not have the lowest score at the table when the round concludes.

**Winner determination:** The player with the **lowest total** wins. Tiebreaker: lower score in the final round. If still tied, both share the win.

**No elimination:** Every player plays every round until the game ends.

---

## Strategic Fit

This feature completes the core loop of the product brief. Game Setup handles the start; Score Tracking handles everything in between and the end. Together they are the whole product.

`GameSetupView.init(initialPlayers:)` already accepts a pre-populated player list for the play-again flow — the connection point is already in the codebase.

---

## Design Principles

**Speed of entry is everything.** Score entry should be fast — a number pad, not a full keyboard. Confirming a round's scores should be one tap.

**Running totals are always visible.** Current standings should be obvious at a glance. The current leader (lowest score) should be clear without calculation.

**The doubling rule needs special handling.** The UI should prompt or make it easy to flag the player it applies to when triggered.

**The end of the game should feel like a moment.** A clear, satisfying win state — not just a table row update.

---

## What Success Looks Like

A group finishes a round, one person picks up the phone, enters all scores in under 20 seconds, taps confirm, and puts the phone back down. Everyone can see the standings. This repeats until someone crosses 100, the final round is resolved (with doubling if needed), and the app shows the winner clearly. Tapping "New Game" returns to setup with names pre-filled.
