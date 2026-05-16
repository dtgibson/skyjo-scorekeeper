# Design Spec — Game Setup

## Visual Direction
Native iOS aesthetic throughout — clean, minimal, and instantly scannable. The primary brand color (#3730A3, dark purplish blue) anchors the title and the main action button. Typography uses SF Rounded for warmth without being childish. The overall feeling is immediate clarity: a user opens the app and knows exactly what to do without instruction.

## Screens / Views

### Game Setup Screen (Home Screen)
The app launches directly to this screen — no splash, no menu.

**Layout:** Vertical stack. Title and subtitle centered at top. Player list in the middle. Start Game button pinned near the bottom.

**Header:**
- App title "Skyjo Scorekeeper" — large (40px), weight 800, brand color #3730A3, letter-spacing -1.5px. This is the easter egg long-press target (3 seconds).
- Subtitle "Who's playing today?" — 15px, color #8E8E93, below the title.

**Player List:**
- Grouped table-view style: white card with 14px border-radius, subtle shadow.
- Each row is 54pt tall. Contains: avatar circle (30pt), text field, remove button or spacer.
- Avatar circle: brand-tinted background (#3730A3 at 13% opacity) with the player number when empty; fills solid brand color (#3730A3) with white initial letter once a name is typed.
- Text field: 17px, no border, full-width. Placeholder is light grey (#C7C7CC). Error state highlights placeholder in red and adds a faint red background tint.
- Remove button: 24pt red circle (#FF3B30) with a white horizontal bar. Only shown when more than 2 players exist. Hidden at minimum.
- Section label: "PLAYERS" in 13px uppercase, grey (#8E8E93), above the card.

**Add Player Button:**
- Separate white card below the player list, same radius and shadow.
- 30pt green circle (#34C759) with a + icon, followed by "Add Player" label at 17px.
- Hidden when player count reaches 8.

**Start Game Button:**
- Full-width, 58pt tall, 16px border-radius.
- Brand color (#3730A3) when enabled. Opacity 28% when disabled.
- White label "Start Game" at 17px/600 weight, with a play triangle icon to the left.
- On successful start: transitions to green (#34C759) with a checkmark for 2 seconds, then resets.

**Status Note:**
- 13px centered text below the Start button.
- Disabled state: "Enter at least 2 names to start" in light grey.
- Ready state: "{N} players ready" in green (#34C759).

### Easter Egg Overlay
Triggered by a 3-second long-press on the app title. No visual hint.

- Full-screen frosted glass backdrop (blur 16px, dark overlay).
- Centered card: white, 22px border-radius, generous padding.
- 🌸 emoji at 52px.
- Message: "Happy Mother's Day, Shawn!" at 24px/700 weight.
- Dismiss button: brand color, 13px border-radius. Tapping outside the card also dismisses.
- Card animates in with a spring scale (0.9 → 1.0).

## Component Usage
- Grouped list rows — iOS-style table view cells, implemented as SwiftUI `List` with `.insetGrouped` style
- Text fields — SwiftUI `TextField` with custom styling
- Buttons — SwiftUI `Button` with custom label views
- Overlay — SwiftUI `.sheet` or `.overlay` with `.ultraThinMaterial` background for the easter egg

## Design Tokens Applied
- **Primary:** #3730A3 — title, avatar fills, Start button, easter egg dismiss button
- **Success:** #34C759 — Add Player icon, ready state note, start success flash
- **Destructive:** #FF3B30 — remove player button
- **Background:** #F2F2F7 — screen background (iOS systemGroupedBackground)
- **Surface:** #FFFFFF — list cards (iOS secondarySystemGroupedBackground)
- **Text primary:** #1C1C1E — player names, labels
- **Text secondary:** #8E8E93 — subtitle, section label, disabled note
- **Typography:** SF Rounded (`.fontDesign(.rounded)` in SwiftUI), system sizes

## Interaction Notes
- Avatar updates in real time as the user types — shows player number when empty, initial letter (filled brand color) when a name exists
- Start button enables/disables reactively as names are entered
- Empty fields among populated ones highlight red on a failed start attempt (do not auto-remove)
- Long-press on title (3 seconds) shows easter egg — no visual feedback during press
- Easter egg dismisses on background tap or dismiss button
- Add Player button scrolls into view and focuses the new field after adding
- At 8 players the Add Player button disappears; at 2 players the remove buttons disappear

## Content Notes
- Subtitle copy: "Who's playing today?" — warm, conversational, present tense
- Button copy: "Start Game" — direct, no punctuation
- Status copy when ready: "{N} players ready" — concise, affirming
- Easter egg message: "Happy Mother's Day, Shawn!" — exact string, no variation
