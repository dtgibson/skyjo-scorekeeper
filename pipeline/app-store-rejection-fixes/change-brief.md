# Change Brief — App Store Rejection Fixes

## What is changing

Two fixes to address App Store rejection feedback. First, a toolbar
button is added to ScoringView that lets the user end the current game
and return to the setup screen — satisfying Apple's Guideline 4
requirement for expected iOS navigation. Second, a SUPPORT.md file is
added to the repo root with honest, personal copy explaining the app is
a free personal project with limited support available; a contact email
is provided for genuine bug reports. The support URL in App Store Connect
is then updated by the user to point to the new file.

## Why now

App Store rejection. Both issues must be resolved before resubmission.

## User-facing impact

A new "End Game" button appears in the ScoringView toolbar. Tapping it
shows a confirmation alert; confirming returns the user to the player
setup screen. All other behavior is unchanged.

## Decisions touched

- "Root navigation uses a Route enum, not NavigationStack" — not
  reversed. The Route enum still controls navigation; ScoringView gains
  a callback to trigger the setup route from within the game.

## What done looks like

- Tapping "End Game" in the scoring view shows a confirmation alert.
- Confirming the alert returns the user to the player setup screen.
- SUPPORT.md exists at repo root with appropriate content and tone.
- App Store Connect support URL updated to point to SUPPORT.md.
