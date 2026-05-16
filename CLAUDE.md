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
- Brand color: `Theme.brand` (indigo #3730A3); HC variant: `Theme.brandHighContrast`
- Player avatar colors: `Theme.playerColor(at: index, highContrast: Bool)` and `Theme.playerTextColor(at: index, highContrast: Bool)` — always use position index, never derive from name; pass `colorSchemeContrast == .increased` for the HC parameter
- Typography: SF Rounded throughout (`Font.system(..., design: .rounded)`)
- Corner radii: 14pt for cards/rows, 16pt for primary button
- Font.system text-style overload parameter order: `design:` before `weight:` — `.system(.body, design: .rounded, weight: .bold)`. The fixed-size overload has weight before design.

### Accessibility
- All decorative elements (avatars, emoji, drag handles) must be `.accessibilityHidden(true)`
- Compound rows must use `.accessibilityElement(children: .ignore)` with a descriptive `.accessibilityLabel`
- All animations must be wrapped: `reduceMotion ? nil : .easeInOut(...)` — read `@Environment(\.accessibilityReduceMotion)`
- All views that use brand or player colors must read `@Environment(\.colorSchemeContrast)` and pass HC variants when `colorSchemeContrast == .increased`
- All fixed-height rows must use `frame(minHeight:)` not `frame(height:)` to support Dynamic Type

### CI/CD
- Runner: `macos-15`, no Xcode version pinned — never add `xcode-select` pin; it breaks when pbxproj is saved by a newer Xcode
- Test destination: `platform=iOS Simulator,OS=latest,name=iPhone 16` — named simulator, not UDID lookup
- Code signing: disabled for simulator tests (`CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`)
- Workflow file: `.github/workflows/pipeline.yml`
