# Strategic Brief — Session Persistence

## What We're Building
Automatic save and restore of an in-progress Skyjo game. The current game state — player names, all round scores, and the current round number — is written to device storage continuously and restored the next time the app opens.

## Why Now
The app's core gameplay loop is solid, accessible, and now available in 35 languages. The one remaining friction that can interrupt a session is entirely outside the user's control: a phone call, a notification, the OS reclaiming memory. Fixing this closes the last gap between the app and a physical scorepad — which never loses your place.

## The User Problem
A group is mid-game when someone gets a call. The player tabs out to answer, and when they return the app has reset. All the round data is gone. There's no way to recover it. The game either restarts or the group gives up and uses paper. This isn't an edge case — it's a near-certainty for any game that takes 30+ minutes.

## Success Criteria
- Quitting the app mid-game and reopening it brings up the exact game state that was left, with no data loss
- Backgrounding the app for any duration (including overnight) and returning to it restores the game
- When a game ends naturally (winner declared) or the user explicitly ends it, the saved state is cleared — so the next launch starts fresh
- Users who have never experienced a save/restore cycle notice nothing unusual — it just works

## Scope
- Save the active `GameSession` to local device storage whenever it changes
- Restore it automatically on next launch if a game was in progress
- Clear saved state on game over, "End Game", "New Game — Same Players", and "Start Fresh"
- On-device storage only — no network, no iCloud sync

## Out of Scope
- Completed game history (viewing past games after they've ended)
- iCloud sync across devices
- Named/saved sessions ("save this game to resume later")
- Any UI indicator that state is being saved — no "save game" button, no user action required

## Key Decisions
- Persistence is automatic and invisible — no "save game" button, no user action required
- Scope is strictly the in-progress game only; completed games are not retained
- The save is cleared on any natural or intentional game ending, so there's no ambiguity about what to restore on next launch
