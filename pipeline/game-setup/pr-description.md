## Game Setup

### What this does
The game setup screen is the home screen of Skyjo Scorekeeper. Players enter their names (2–8), then tap Start Game to begin. The screen accepts optional pre-populated players for the future play-again flow. A hidden easter egg appears on a 3-second long-press of the app title.

### How to test
1. Run the app on an iPhone simulator (iOS 17+)
2. Verify the setup screen appears immediately on launch — no splash screen
3. Type names in the two default fields; verify Start Game becomes active with 2+ valid names
4. Tap the green + button to add players; verify it disappears at 8
5. Tap a red circle to remove a player; verify it disappears at 2 players
6. Fill some fields and leave one blank; tap Start Game — verify the blank field highlights red
7. Hold "Skyjo Scorekeeper" for 3 seconds; verify the easter egg appears and is dismissible

### Notes for reviewer
- `GameSetupView(initialPlayers:)` accepts optional pre-populated players for the future win screen
- `GameState.committedPlayers()` returns trimmed, validated players ready to start a game
- The easter egg uses `.ultraThinMaterial` — renders as liquid glass on iOS 26+
- No persistence — all state is in-memory for the session only
- `PrimaryButtonStyle` is defined in `GameSetupView.swift`; extract to a shared file when a second use appears
