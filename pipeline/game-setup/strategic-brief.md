# Strategic Brief — Game Setup

## What We're Building
The initial screen a user sees when they open Skyjo Scorekeeper: enter player names, set up the game, and start scoring. Also the "new game" flow that appears after a win, and a hidden easter egg message for a specific someone.

## Why Now
This is the only screen that needs to exist before anything else. There is no scorekeeper without it. It ships first because everything — round entry, score tracking, winner declaration — is downstream of this moment.

## The User Problem
Someone sits down to play Skyjo and reaches for their phone to keep score. They need to enter player names and get into the game in under 30 seconds, without instructions, without creating an account, without navigating a menu. Every extra tap is friction that belongs to the game, not the app. After the game ends, they want to play again immediately — without re-entering everyone's names if the group hasn't changed.

## Success Criteria
- A user can open the app, enter 2–8 player names, and start a game in under 30 seconds
- The interface is immediately scannable — there is no step that requires explanation
- Adding and removing players feels effortless on a touchscreen
- The game cannot start with fewer than 2 players or more than 8 (Skyjo's rules)
- After a win, the group can start a new game in two taps — once to choose "new game", once to confirm players
- The easter egg is discoverable by accident but not obviously telegraphed

## Scope
- App launch screen / home screen
- Player name entry (2–8 players)
- Add and remove player controls
- Start game action
- Basic validation (min 2, max 8 players; no blank names)
- "Play again" button on the win screen
- New game flow: keep same players or edit before starting
- Hidden easter egg: a gesture or tap sequence that reveals "Happy Mother's Day, Shawn!"

## Out of Scope
- Saving or recalling previous player names across cold app launches
- Game history or past sessions
- Settings or preferences
- Onboarding or tutorial
- Any network activity

## Key Decisions
- The game setup screen is the home screen — there is no separate landing page
- Player count is constrained to Skyjo rules (2–8)
- Player names from the just-completed game pre-populate the new game setup when "play again" is chosen
- No persistence of player names between cold app launches in v1
- The easter egg trigger and presentation will be defined during design
