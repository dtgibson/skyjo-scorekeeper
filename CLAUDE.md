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
- All open windows share one `GameSession`. Anything every window must agree on (win screen, open sheets) derives from session state such as `session.isGameOver`, never a per-view flag. Rules for a finished game live in the model (`commitRound` ignores rounds after game over), not only in the UI

### Layout (iPhone, iPad, any window size)
- `Theme.contentMaxWidth` (600pt) is the single width ceiling — never hardcode a max width per-view
- Use the two-frame idiom for primary content regions: `.frame(maxWidth: Theme.contentMaxWidth).frame(maxWidth: .infinity)`
- The app supports both iPhone and iPad — new views must apply this pattern. iPhone runs in portrait and both landscapes (never upside-down), so check new screens sideways on a standard iPhone too
- Screens adapt only by the space they are offered: derive a `LayoutMode` (`.tall` / `.short` / `.wide`) with `.onAvailableSize(update:_:)` in `Theme.swift`. It is the single home for the thresholds (575pt short, 560pt wide, 1.2 ratio) — never hardcode them, and never branch on orientation, device idiom, `UIScreen`, or size class
- Use `onAvailableSize` rather than a hand-rolled `GeometryReader`: it takes exactly the offered space and measures inside `.ignoresSafeArea(.keyboard)`, so large text and the keyboard can't flip the layout. Keep view state above the mode-specific subviews so a live resize keeps what's been typed
- iPhone Duo's fold and camera are part of the space offered: `.onAvailableSpace(update:_:)` in `Theme.swift` reads them (`ReservedRegion` `.division` / `.occlusion`, gated `#available(iOS 27.1, *)`) into `AvailableSpace`, the single home for that logic. When a fold runs top to bottom through a screen, `space.pages` gives its two pages: lay them out with `HStack(spacing: pages.spacing)` and `.page(pages.leading)` / `.page(pages.trailing)` — list on the left page, heading and primary action on the right, nothing in the fold. A side-to-side fold (tabletop) keeps the tall layout; only overlays and the entry sheet use `upperPage` / `lowerPage`
- Lists may cross the fold; controls may not. Never use `DeviceHinge` / `onHingeChange` or branch on pose — adapt to space and regions only
- iOS 27.1 system chrome does not avoid the fold: an inline bar title is centred on it, and a sheet is shown as a centred card across it. On two pages, blank the bar title and render it as the right page's heading (`.isHeader`, same string key). A sheet the fold crosses uses the fold as its divider — never resize the sheet's presentation to dodge it; the system overrides that

### Navigation and toolbars
- Root navigation is the `Route` enum in `SkyjoScorekeeperApp`. A screen may wrap itself in a local `NavigationStack` only to host a system toolbar — never to push screens
- A toolbar button with a title uses an `HStack` of symbol + `Text` (symbol `.accessibilityHidden(true)`) — iOS 27 drops the title of a toolbar `Label` even with `.labelStyle(.titleAndIcon)`
- `AccentColor` in the asset catalog is empty, so system-tinted controls don't pick up the brand — tint them explicitly with `Theme.brand` / `Theme.brandHighContrast`

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
- Runner: `xcode-27`; never add an `xcode-select` pin — it breaks when pbxproj is saved by a newer Xcode. CI must build with the Xcode the app ships with; if the preview image is flaky, fall back to `macos-26`
- The app ships on Xcode 27.1 (`ReservedRegion` is 27.1-only) but the image defaults to 27.0, so the job sets `DEVELOPER_DIR: /Applications/Xcode_27.1.app/Contents/Developer`. Delete that line once the image's default Xcode reaches 27.1. Locally, `xcode-select` may point at the Command Line Tools: prefix `xcodebuild`/`xcrun` with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`
- Test destination: `platform=iOS Simulator,OS=latest,name=iPhone 17` — named simulator, not UDID lookup. Under Xcode 27.1 it resolves to iPhone 17 on iOS 27.0, the newest runtime with that device (the 27.1 runtime ships only iPhone Duo)
- Code signing: disabled for simulator tests (`CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`)
- Workflow file: `.github/workflows/pipeline.yml`

### Simulator checks
- iPhone Duo poses (open, half-open, tabletop, flipped) can only be set in Xcode's Device Hub, which needs an unlocked Mac screen and has no scripting interface. Without it, `devicectl device appResize` gives the app an exact window size (open 951×669pt, tabletop 669×951pt, closed 466×678pt) for layout checks, but no real fold
- Capture layout evidence with the shipped Info.plist settings, orientation especially. If a check needs a build override, the PR description's Verification section must say so
- On the Duo simulator, `simctl io screenshot` without `--display` captures the inner display, which is dark while closed — pass `--display=1` (the outer display) for closed-pose captures; an `appResize` window is `--display=5`
- `xcrun devicectl device orientation set --device <udid> portrait|landscapeLeft|landscapeRight|portraitUpsideDown` rotates a simulator from the command line

### Public repo
- The repo is public. Licensed third-party artwork (Apple Design Resources bezels and templates, `.psd` files) never goes in it: `**/mockup-assets/bezels/` is gitignored and `store-assets/tools/fetch-bezels.sh` downloads bezels outside the repo. Stage explicit paths near such files — never `git add -A` or `git add pipeline/` — and check `git diff --cached --name-only` for bezel or design-resource files before committing. Finished composites (the app inside a bezel) are fine to commit
- No machine-specific addresses in committed docs: no Tailscale hostnames or live preview links with local ports. Write a placeholder (`https://<your-tailnet-host>/path`); real links belong in gitignored run notes

### App Store listing
- Store assets live in `pipeline/iphone-duo-store-listing/store-assets/`. `tools/compose.swift` rebuilds every screenshot and the product page header from the raw captures in `tools/captures/` (steps in `tools/README.md`). Retake captures with the scripts in `tools/capture/`, applying the demo-data patch to a scratch copy only, never the real source
- Clean status bar: `tools/capture/statusbar.sh` runs `xcrun simctl status_bar <id> override --batteryState discharging --batteryLevel 100 --wifiBars 3 …`, then the 9:41 `--time` last (a later override breaks the weekday). `--batteryState charged` draws a charging bolt. `prep-sim.sh` also forces the 12-hour clock; simulators default to 24-hour ("09:41")
- Screenshots, subtitle, description and keywords change only with a new version. Promotional text and the product page header (Asset Library) change on the live version
- iPhone Duo screenshots go through the Asset Library as `APP_IPHONE_DUO`; the published API has no Duo display type. Outer and inner sizes, upright and sideways, mix in one set
- Keep key content inside each Apple template's safe area — the product page header's art safe area is only x 1097–2742, y 493–1153 of 3840×1646 — and check every set in App Store Connect's preview tool before submitting
- App Store Connect writes (profiles, versions, metadata, screenshots, submission) use API key `QJA25M7XHM` with manual signing; the environment's default key is read and upload only
