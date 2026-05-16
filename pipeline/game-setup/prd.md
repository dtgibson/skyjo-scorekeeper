# PRD — Game Setup
**Feature:** game-setup
**Session:** 001
**Date:** 2026-05-09
**Stage:** 2 — The Planner
**Source:** strategic-brief.md (approved)

---

## Feature Overview
The game setup screen is the home screen of Skyjo Scorekeeper. It collects player names, enforces Skyjo's player count rules, and starts the game. It also handles the "play again" flow after a completed game and contains a hidden easter egg.

---

## User Stories

**US-01** — As a player, I want to enter names for everyone at the table, so that the app can track scores for each person.

**US-02** — As a player, I want to add and remove player slots easily, so that I can adjust the group without friction.

**US-03** — As a player, I want the app to stop me from starting with too few or too many players, so that the game follows the rules.

**US-04** — As a player who just finished a game, I want a quick way to start again with the same group, so that we don't have to re-enter everyone's names.

**US-05** — As a player starting a new game after a win, I want to edit the player list before starting, so that I can add or remove someone if the group has changed.

**US-06** — As a curious person tapping around the app, I want to stumble on a hidden message, so that it feels like there's a little personality in the app.

---

## Functional Requirements

### Setup Screen

**FR-01** — The app shall display the game setup screen immediately on launch with no intermediary screen.

**FR-02** — The app shall show a minimum of 2 player name fields on launch, each empty and editable.

**FR-03** — The app shall allow the user to add player name fields up to a maximum of 8.

**FR-04** — The app shall hide the "Add Player" control once 8 player fields are present.

**FR-05** — The app shall allow the user to remove any player name field, provided at least 2 fields remain.

**FR-06** — The app shall display a "Start Game" button at all times on the setup screen.

**FR-07** — The app shall keep the "Start Game" button disabled until at least 2 fields contain non-blank names.

**FR-08** — The app shall trim leading and trailing whitespace from player names before validation.

**FR-09** — If the user attempts to start the game with any blank name fields present among filled ones, the app shall highlight the blank fields to indicate they need attention.

### Play Again Flow

**FR-10** — The app shall display a "New Game" button on the win screen.

**FR-11** — When "New Game" is tapped, the app shall navigate to the game setup screen pre-populated with the names from the just-completed game.

**FR-12** — The pre-populated setup screen shall be fully editable — names can be changed, players added or removed — before starting.

**FR-13** — If the user makes no changes to the pre-populated setup screen, tapping "Start Game" shall immediately begin a new game with the same players.

### Easter Egg

**FR-14** — The app shall reveal the message "Happy Mother's Day, Shawn!" when the user performs a specific hidden gesture on the setup screen.

**FR-15** — The easter egg trigger shall be a long-press (3 seconds) on the app title.

**FR-16** — The easter egg message shall appear as a modal or overlay.

**FR-17** — The easter egg message shall be dismissible by tapping anywhere outside it or a dismiss button.

**FR-18** — The easter egg trigger shall have no visual indicator, tooltip, or hint in the UI.

---

## Non-Functional Requirements

**NFR-01 — Compatibility:** The app shall support iOS 17.0 and later.

**NFR-02 — Touch targets:** All tappable controls shall meet Apple HIG minimum touch target size of 44×44 points.

**NFR-03 — Accessibility:** All interactive elements shall have accessibility labels set for VoiceOver.

**NFR-04 — Performance:** The setup screen shall be fully interactive within 1 second of cold app launch.

**NFR-05 — Privacy:** The app shall not collect, transmit, or store any user data outside of the device.

---

## Out of Scope
- Persisting player names between cold app launches
- Game history or saved sessions
- Settings or preferences screen
- Onboarding, tutorial, or help screens
- Any network requests of any kind
- Duplicate name detection or warnings

---

## Open Questions

1. **Should the easter egg be available on screens other than the setup screen (e.g. mid-game)?**
   Default assumption: setup screen only.

2. **Should blank player fields be automatically removed when Start Game is tapped, or highlighted as errors?**
   Default assumption: highlighted as errors — the user should explicitly remove fields they don't want.

---

## Success Metrics

| ID | What's Being Verified | Pass Condition |
|---|---|---|
| QA-01 | App launches to setup screen | Setup screen is the first screen shown; no splash or menu precedes it |
| QA-02 | Default state has 2 empty fields | Exactly 2 empty name fields visible on cold launch |
| QA-03 | Add player up to max | Tapping Add Player adds a field; control disappears at 8 players |
| QA-04 | Remove player down to min | Tapping remove on a field removes it; control disappears at 2 players |
| QA-05 | Start Game disabled with < 2 names | Button is non-interactive until 2+ non-blank names exist |
| QA-06 | Whitespace trimming | A name of "  Dave  " is treated as "Dave" for validation |
| QA-07 | Blank field on start attempt | Empty fields among populated ones are visually highlighted |
| QA-08 | New Game button on win screen | Button is present and tappable on the win/end screen |
| QA-09 | Play again pre-populates names | Tapping New Game shows setup screen with previous players' names filled in |
| QA-10 | Pre-populated screen is editable | Names can be changed, fields added/removed before starting |
| QA-11 | Easter egg trigger | Long-pressing the app title for 3 seconds reveals the message |
| QA-12 | Easter egg message content | The message reads exactly: "Happy Mother's Day, Shawn!" |
| QA-13 | Easter egg dismissal | Tapping outside the overlay or a dismiss control closes it |
| QA-14 | No visual easter egg hint | No tooltip, underline, animation, or visual indicator on the title |
| QA-15 | Touch target sizes | All controls pass 44×44pt minimum size check |
