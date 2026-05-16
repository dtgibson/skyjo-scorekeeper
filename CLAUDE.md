# CLAUDE.md

This file is auto-loaded by Claude Code at the start of every session.
It holds pipeline conventions, tool rules, and project-specific
decisions that all builders must follow.

## Pipeline Overview

This project uses the Weft framework. Run /new-project to get started.

## Conventions

### Source files
Swift source files live in iCloud Drive (this directory) and are copied into the Xcode project manually. Do not attempt to edit files inside the `.xcodeproj` package or Xcode's DerivedData. Write to the iCloud path and ask the user to drag files into Xcode.

### Models
- `Player` is a value type (`struct`) with `id: UUID` and `name: String`
- `GameState` is `ObservableObject` with `@Published var players: [Player]`
- Import `Combine` in any file that uses `ObservableObject`

### iPad layout
- `Theme.contentMaxWidth` (600pt) is the single width ceiling — never hardcode a max width per-view
- Use the two-frame idiom for primary content regions: `.frame(maxWidth: Theme.contentMaxWidth).frame(maxWidth: .infinity)`
- The app supports both iPhone and iPad — new views must apply this pattern

### Styling
- Brand color: `Theme.brand` (indigo #3730A3)
- Player avatar colors: `Theme.playerColor(at: index)` and `Theme.playerTextColor(at: index)` — always use position index, never derive from name
- Typography: SF Rounded throughout (`Font.system(..., design: .rounded)`)
- Corner radii: 14pt for cards/rows, 16pt for primary button

### CI/CD
- Runner: `macos-15`, no Xcode version pinned (uses default, currently 16.4)
- Test destination: resolved at runtime via `xcrun simctl list` UDID lookup
- Code signing: disabled for simulator tests (`CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`)
- Workflow file: `.github/workflows/pipeline.yml`
