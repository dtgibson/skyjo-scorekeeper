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
- The doubling rule has one home: `GameSession.isDoubled(raw:minOther:)`. Views (e.g. the live entry preview) must call it, never reimplement it
- Score thresholds are named: `GameSession.bustThreshold` (100) and `dangerThreshold` (85), surfaced via `GameSession.scoreStatus(for:)`. Never hardcode 85/100

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
- SF Rounded has no italic face — `.italic()` is a silent no-op on `.system(design: .rounded)`. For emphasis use a heavier `weight:`, `.underline()`, or switch that element to `design: .default` (which does italicize).

### Accessibility
- All decorative elements (avatars, emoji, drag handles) must be `.accessibilityHidden(true)`
- Compound rows must use `.accessibilityElement(children: .ignore)` with a descriptive `.accessibilityLabel`
- All animations must be wrapped: `reduceMotion ? nil : .easeInOut(...)` — read `@Environment(\.accessibilityReduceMotion)`
- All views that use brand or player colors must read `@Environment(\.colorSchemeContrast)` and pass HC variants when `colorSchemeContrast == .increased`
- All fixed-height rows must use `frame(minHeight:)` not `frame(height:)` to support Dynamic Type
- Tappable controls must have a touch target ≥ 44pt — wrap small visuals in a `.frame(width: 44, height: 44).contentShape(Rectangle())` rather than enlarging the visual
- Announce meaningful state changes to VoiceOver with `AccessibilityNotification.Announcement(...).post()` (e.g. round committed, undo, game won) — silent state changes leave VoiceOver users with no feedback
- Never recover data by parsing a display string for an accessibility label — compute the value from the model (the doubling label takes the doubled `Int` directly, not a split of the "×2 → N" text)

### Localization
- All new user-facing strings and VoiceOver accessibility labels must have entries in `SkyjoScorekeeper/Localizable.xcstrings`
- `Text("literal")` and SwiftUI modifier string literals (`.accessibilityLabel("literal")`, `Button("label")`, etc.) are `LocalizedStringKey` and auto-localize — no code change needed, just add the key to the catalog
- Computed `String` properties do NOT auto-localize — use `String(localized: "key")` for any string built in Swift code before being passed to a view modifier
- Format specifier mapping for `String(localized:)`: `\(intValue)` → `%lld` catalog key; `\(stringValue)` → `%@` catalog key
- Count-based strings that need plural forms (e.g. "N rounds played") use CLDR `variations.plural` in the catalog — add `one` and `other` forms for English; other locales need all required CLDR categories for their language

### Session Persistence
- `SessionStore` is a static struct — never instantiate it; call `SessionStore.save(_:)`, `SessionStore.load()`, `SessionStore.clear()` directly
- `GameSessionSnapshot` is the serialization boundary — it holds `[Player]` and `[Round]`; all fields are `Codable` via synthesis
- `GameSession` has two inits: `init(players:)` clears saved state (fresh game), `init(snapshot:)` restores without clearing — never mix them up
- `init(snapshot:)` initializes `@Published` backing storage directly with `_rounds = Published(initialValue: snapshot.rounds)` — this is intentional; do not change it to `self.rounds = snapshot.rounds`
- All `SessionStore` operations fail silently — do not add error propagation or alerts
- `GameSessionSnapshot.schemaVersion` is an optional `Int` (current: `GameSessionSnapshot.currentVersion`) — keep it optional so pre-versioning files decode as `nil`. When the persisted model changes, bump `currentVersion` and branch on it to migrate

### CI/CD
- Runner: `macos-15`, no Xcode version pinned — never add `xcode-select` pin; it breaks when pbxproj is saved by a newer Xcode
- Test destination: `platform=iOS Simulator,OS=latest,name=iPhone 16` — named simulator, not UDID lookup
- Code signing: disabled for simulator tests (`CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`)
- Workflow file: `.github/workflows/pipeline.yml`
