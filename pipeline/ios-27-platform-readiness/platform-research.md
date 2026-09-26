# Platform Research — iOS 27 Platform Readiness

Researched 2026-09-24 by The Evaluator. Everything below is verified against the
linked sources unless marked **Unverified**. Local checks were run with the
installed Xcode 27.0 (27A266a) on macOS 27.0.

---

## 1. What changed at Apple

### 1.1 App Store submission requirements

| # | Item | Status | Detail | Source |
|---|---|---|---|---|
| A1 | Xcode 26 / iOS 26 SDK minimum | **Hard requirement, in effect since 2026-04-28** | "Apps uploaded to App Store Connect must be built with Xcode 26 or later using an SDK for iOS 26…" | [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) |
| A2 | iOS 27 SDK minimum | **Hard requirement, "Starting April 2027"** (no exact day given) | "iOS and iPadOS apps must be built with the iOS 27 & iPadOS 27 SDK or later." App Store has accepted Xcode 27 builds since 2026-09-14. | [Apple news, 2026-09-09](https://developer.apple.com/news/?id=k1mtkt1k), [Xcode 27 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes) |
| A3 | Launch screen required for 27 SDK builds | **Hard requirement** | "Apps built with the 27.0 SDK… must contain one of: `UILaunchStoryboardName`, `UILaunchStoryboards`, `UILaunchScreen`, or `UILaunchScreens`. Apps that don't include a launch screen are rejected…" (168247372) | [iOS & iPadOS 27 release notes → UIKit](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes) |
| A4 | Scene-based lifecycle | **Hard requirement** (27 SDK) | "Apps built with the latest SDK must adopt the scene-based life cycle or they fail to launch." (141837548) | Same, UIKit → Deprecations; [WWDC26 session 278](https://developer.apple.com/videos/play/wwdc2026/278/) |
| A5 | Age rating questions incl. social media disclosure | **Hard requirement** (App Store Connect, not code) | New Time Allowances; "If your app or game includes social media capabilities, you'll need to indicate them in App Store Connect." Earlier questionnaire deadline was 2026-01-31. | [Apple news, 2026-09-09](https://developer.apple.com/news/?id=k1mtkt1k), [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) |
| A6 | Minimum deployment target iOS 13+ | Hard requirement (since 2026-09-09) | App targets iOS 17 — compliant. Xcode 27 still supports iOS 15+ deployment. | [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) |
| A7 | Privacy manifest / required-reason APIs | Hard requirement (since 2024) | App ships `PrivacyInfo.xcprivacy`; uses no required-reason APIs (no UserDefaults, no file-timestamp APIs). Compliant. | [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) |
| A8 | Accessibility Nutrition Labels | **Best practice** (voluntary; Apple says required "in the future", no date announced) | Declared in App Store Connect → App Accessibility. **Unverified:** any enforcement date — none found. | [ASC help](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/manage-accessibility-nutrition-labels/) |
| A9 | Liquid Glass opt-out removed | Behavior change | `UIDesignRequiresCompatibility` is reported ignored when building with the 27 SDKs. App never set it — no impact. **Unverified** against Apple's own doc page (page body did not load); corroborated by multiple third-party reports. | [Apple forums](https://developer.apple.com/forums/thread/801712), [Donny Wals](https://www.donnywals.com/opting-your-app-out-of-the-liquid-glass-redesign-with-xcode-26/) |

### 1.2 iOS 27 / iPadOS 27 changes relevant to this app

| # | Change | Kind | Detail | Source |
|---|---|---|---|---|
| B1 | **iPhone apps are fully resizable** | Behavior change (27 SDK) | In iPhone Mirroring on Mac and iPhone apps on iPad, "an app's supported interface orientation is a preference… It will be ignored when your app is running in a resizable environment." Apps are "expected to dynamically adjust to any available scene size." | [WWDC26 session 278](https://developer.apple.com/videos/play/wwdc2026/278/) |
| B2 | Orientation/idiom checks discouraged | Best practice | "Stop checking the user interface idiom for any layout decisions… Use size classes instead." Avoid `UIScreen.main`; use size classes or local geometry. | Same |
| B3 | `UIRequiresFullScreen` now = discrete resizing | Behavior change | No longer a full opt-out; framed for games. App does not set it. | Same; [iOS 27 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes) |
| B4 | iPad: orientations no longer gate continuous resizing | Behavior change | Fixed in RC (166422120). App is already universal and resizable on iPad. | [iOS 27 release notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-27-release-notes) |
| B5 | `@State` is now a macro | Source-compat change | Some init-assignment patterns no longer compile. **Verified locally:** the app's `_route = State(initialValue:)` in `SkyjoScorekeeperApp.init` compiles cleanly under Xcode 27. | Same, SwiftUI section |
| B6 | Sheets/popovers reset control environment values | Behavior change | `controlSize`, `buttonSizing`, `ButtonBorderShape` reset inside sheets. App sets none of these — no impact. | Same, SwiftUI (167448274) |
| B7 | Liquid Glass tuned in iOS 27 | Automatic | System components (sheets, alerts, toolbars) pick up the iOS 27 look on rebuild. No code change needed; custom-drawn chrome does not. | [WWDC26 SwiftUI guide](https://developer.apple.com/wwdc26/guides/swiftui/) |
| B8 | `PreviewProvider` deprecated | Deprecation | App has no previews — no impact. | [Xcode 27 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27-release-notes) |
| B9 | Icon Composer 2 / new icon rendering | Best practice | Icon Composer 2.0 adds a "sharper rendering mode for upcoming 2027 operating systems"; asset-catalog PNG icons remain supported and get system-applied glass. **Unverified:** exactly how iOS 27 renders legacy PNG icons (no official detail). Icon Composer 2 `.icon` files crash Xcode 26.5's actool — toolchain must be Xcode 27. | Xcode 27 release notes (Icon Composer section); [MacRumors](https://www.macrumors.com/2026/06/16/ios-27-revamps-app-icons/); [Apple forums](https://developer.apple.com/forums/tags/icon-composer) |
| B10 | Xcode 27 toolchain | Environment | Requires macOS Tahoe 26.6+ on Apple silicon; ships Swift 6.4 (Swift 5 language mode still supported). | Xcode 27 release notes |

### 1.3 iPhone Duo — confirmed real

Apple announced **iPhone Duo**, its first foldable iPhone, on 2026-09-09. Pre-orders
2026-10-16, ships **2026-10-23 with iOS 27.1**.
Source: [Apple Newsroom](https://www.apple.com/newsroom/2026/09/apple-unveils-iphone-duo/),
[HIG: Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo).

- **Displays:** outer 5.4" (5.36" rect.), inner 7.6" (7.58" rect.); same aspect ratio;
  passport shape, wider than tall when open. The outer display is "wider and shorter
  than the display on other iPhone devices." **Unverified:** point sizes and exact
  aspect ratio — Apple has not published them.
- **Poses:** closed, open, partially folded (book), propped, flipped, StandBy.
- **Size classes:** outer portrait compact/regular; outer landscape compact/compact;
  inner display **regular/regular** ("it is still an iPhone app").
- **Orientation:** outer display behaves like any iPhone. "The inner display doesn't
  honor your supported interface orientations." (Tech talk also says the app "will
  scale on the inner display" — the two statements are slightly inconsistent.)
- **Multitasking:** Split View (two apps) and **two windows of the same app** on the
  inner display. "If your app supports this on iPad, it will on iPhone Duo as well."
- **SDK tiers** ([Tech talk 111461](https://developer.apple.com/videos/play/tech-talks/111461/)):
  not rebuilt → works, iPhone-shaped region on the inner display; iOS 27 SDK → extends
  further on the inner display; **iOS 27.1 SDK → full edge-to-edge, standard bars lay
  out vertically.** Xcode 27.1 is **beta only** today (released 2026-09-18,
  [9to5Mac](https://9to5mac.com/2026/09/18/apple-releases-xcode-27-1-beta-enabling-iphone-duo-app-development/));
  the iPhone Duo simulator exists only there.
- **Controls:** toolbars, tab bars, and nav controls move to the side edge. Standard
  system bars get this automatically; **custom bars do not**. Custom UI uses the new
  `ReservedRegion` API (iOS 27.1) to avoid the fold and camera regions.
- **Fold:** keep interactive elements out of the fold; scrolling content may pass
  through it. System sheets, alerts, and menus avoid the fold automatically.
- **Safe areas are asymmetric** — never assume equal insets on opposite sides.

### 1.4 Other new hardware (September 2026)

- **iPhone 18 Pro / Pro Max:** same 6.3" / 6.9" sizes; smaller Dynamic Island with up to
  three Live Activities. No impact on this app (content stays in the safe area; no Live
  Activities). [MacRumors recap](https://www.macrumors.com/2026/09/09/apple-september-2026-event-recap/)
- **No new iPad** was announced (OLED iPad mini rumored for October — unverified, not
  relevant until real).

### 1.5 CI runner facts (GitHub Actions)

- `macos-15` default Xcode is **16.4 (iOS 18 SDK)**; newest installed is 26.3. No Xcode 27
  (Xcode 27 needs macOS 26.6+). [macos-15 readme](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)
- `macos-26` (GA) defaults to Xcode 26.6; no Xcode 27 installed.
  [macos-26 arm64 readme](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md)
- **`xcode-27` image** (public preview, arm64 only, macOS 27): Xcode 27.0 is the default;
  iOS 27.0 runtime only; simulators iPhone 17, 17e, 18 Pro, 18 Pro Max, Air + iPads —
  **no "iPhone 16"**. [Changelog](https://github.blog/changelog/2026-09-10-xcode-27-runner-image-now-runs-on-macos-27/),
  [readme](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md)
- "iPhone 17" exists on every candidate image (macos-15 iOS 26.x, macos-26 iOS 26.x,
  xcode-27 iOS 27.0) and locally.

---

## 2. Codebase audit

### 2.1 Local verification (Xcode 27.0, iOS 27.0 SDK)

- Release build for iOS Simulator: **BUILD SUCCEEDED, zero compiler warnings.**
- Full test suite (67 tests) on iPhone 18 Pro / iOS 27.0: **TEST SUCCEEDED, 0 failures.**
- Built `Info.plist`: `UILaunchScreen` present (A3 compliant); `UIApplicationSceneManifest`
  present (A4 compliant); `MinimumOSVersion 17.0`; `UIDeviceFamily [1,2]`;
  `UISupportedInterfaceOrientations~iphone = [Portrait]`, iPad = all four;
  `UIApplicationSupportsMultipleScenes = true`; no `UIRequiresFullScreen`, no
  `UIDesignRequiresCompatibility`.

### 2.2 What is already right

- SwiftUI `App` lifecycle; no `UIScreen.main`, `UIDevice`, idiom checks, orientation
  checks, or `GeometryReader` arithmetic anywhere.
- Backgrounds `ignoresSafeArea()`, all content inside the safe area with per-side padding —
  handles asymmetric insets correctly.
- Width is capped by `Theme.contentMaxWidth` (600pt) with the two-frame idiom — adapts to
  any width.
- Deployment target iOS 17.0 remains supported.

### 2.3 Gaps found

| # | Gap | Where | Why it matters now |
|---|---|---|---|
| G1 | **CI builds with Xcode 16.4 / iOS 18 SDK** | `.github/workflows/pipeline.yml` (`runs-on: macos-15`, no pin) | CI does not validate the SDK the App Store requires (26+ now, 27 from April 2027) or the one the app ships with locally (27.0). It also cannot compile an Icon Composer icon. |
| G2 | CI destination `name=iPhone 16` | same | Does not exist on the `xcode-27` image — the test step would fail the moment the runner moves. |
| G3 | **Score entry sheet assumes tall portrait height** | `ScoreEntrySheet.swift` | ~340pt of fixed, non-scrolling chrome (handle 25 + numpad 4×54pt keys ≈ 248 + confirm ≈ 66). In short windows (iPhone Mirroring resize, small iPad windows, Duo inner display where the portrait lock is ignored, larger Dynamic Type) the player rows collapse to one or none — the user can't see whose score they're typing. |
| G4 | **Win screen assumes tall height** | `WinView.swift` | Hero (52pt spacer + 64pt emoji + headline + subtitle ≈ 220–240pt) and pinned buttons (≈ 120pt) sit outside the scroll view; in short windows the final standings get squeezed out. |
| G5 | Setup screen compact height | `GameSetupView.swift` | Header (~95pt) + start section (~95pt) fixed; tolerable but should be checked with the same compact-height rule. |
| G6 | **Custom top bar instead of a system toolbar** | `ScoringView.swift` `navBar` | Hand-built HStack with fixed `frame(width: 80)` buttons. Misses Liquid Glass bar styling, iPhone Duo's vertical control placement, fold/camera avoidance, and overflow handling; the fixed 80pt widths also risk truncating "End Game"/"Undo" in long locales and at large Dynamic Type. `brand.md` says "Use native SwiftUI components… Do not build custom UI where a system component exists." |
| G7 | Custom drawn sheet grabber, system one hidden | `ScoreEntrySheet.handle`, `ScoringView` `.presentationDragIndicator(.hidden)` | Duplicates a system component; on the Duo inner display sheets are centered and the system grabber adapts. Same brand principle as G6. |
| G8 | **Two windows of the app can disagree** | `SkyjoScorekeeperApp` (shared `@State route`), `ScoringView` (`showWinView` per window) | `UIApplicationSupportsMultipleScenes = true`. Both windows share one `GameSession`; ending the game from window A shows the win screen only in A, while window B keeps a scoreboard for a finished game and could record rounds past game over. Already possible on iPad; iPhone Duo makes two-window use possible on iPhone for the first time. |
| G9 | App icon is flattened PNGs | `Assets.xcassets/AppIcon.appiconset` (light/dark/tinted 1024², RGB, no alpha) | Still supported (system applies glass), but the gradient, white outline, and drop shadow are baked in, so iOS 26/27 can't render real layered depth, and the clear/tinted looks are system-guessed. The artwork is simple (indigo gradient + "-2" glyph) — a good candidate for a layered Icon Composer 2 file. |
| G10 | Numpad keys use fixed `frame(height: 54)` | `ScoreEntrySheet.numpadButton` | Conflicts with the compact-height need in G3. Keys must stay ≥ 44pt. |

---

## 3. Ranked in-scope list

**Required (compatibility / submission)**

1. **R1 — Ship on Xcode 27 / iOS 27 SDK.** Already installed and building clean. No
   code changes needed for the SDK itself; this build is the Xcode 27 release. (A2, A3, A4 verified compliant.)
2. **R2 — Move CI to the Xcode 27 toolchain.** `runs-on: xcode-27` (image default Xcode
   27.0, so no `xcode-select` pin), and change the test destination to
   `platform=iOS Simulator,OS=latest,name=iPhone 17`. Fallback if the preview image is
   unreliable: `macos-26` (GA, Xcode 26.6 — satisfies today's App Store rule, not iOS 27). (G1, G2)
3. **R3 — Every screen works at any window size and aspect ratio.** Height-adaptive
   layouts for the score entry sheet, win screen, and setup screen, keyed off available
   space / vertical size class (never orientation or idiom). Keep the 600pt width cap. (B1, G3–G5, G10)
4. **R4 — Two windows stay consistent.** Finishing or leaving a game in one window must be
   reflected in every open window (no scoring past game over). Preferred: each window
   derives its win-screen presentation from `session.isGameOver` (code-only, keeps iPad
   multi-window). Alternative: declare single-window support (a project setting the user
   changes in Xcode). The Engineer picks the simpler reliable route. (G8)

**Recommended (best practice)**

5. **B-1 — System toolbar on the scoreboard.** Replace the custom top bar with a local
   `NavigationStack` + toolbar items (End Game, Round N title, Undo), each with a title and
   an SF Symbol. Root navigation stays the `Route` enum. (G6)
6. **B-2 — System sheet grabber.** Drop the custom handle; use the system drag indicator. (G7)
7. **B-3 — Layered app icon.** Rebuild the icon as an Icon Composer 2 file (background
   gradient + "-2" glyph layers) so iOS 26/27 renders true glass in default, dark, clear,
   and tinted. Fallback: if a faithful layered source can't be produced, keep the current
   asset-catalog icon — it remains supported. Depends on R2 (CI must be on Xcode 27). (G9)

**User actions in App Store Connect (not code — surface at deploy)**

- Answer the updated age rating questions; declare no social media capabilities. (A5)
- Fill in the Accessibility Nutrition Label (VoiceOver, Larger Text, Dark Interface,
  Differentiate Without Color, Sufficient Contrast, Reduced Motion — per `ACCESSIBILITY.md`,
  verify each against Apple's criteria). (A8)
- Optional: after CI is on Xcode 27, accept Xcode 27's "Update to recommended settings"
  in Xcode (bumps `LastUpgradeCheck`; the project file is user-edited per `CLAUDE.md`).

---

## 4. Follow-up when Xcode 27.1 is final (not this build)

These need the iOS 27.1 SDK, which is beta-only today. The App Store does not accept
builds from beta Xcode, so they can't ship in this release.

- Rebuild with the 27.1 SDK for iPhone Duo edge-to-edge and vertical bar layout (B-1 is
  what makes this pay off).
- Use `ReservedRegion` to keep the pinned primary buttons ("Start Game", "Enter Round N
  Scores", win-screen actions) out of the fold when the inner display is partially folded.
  Everything inside the system sheet already avoids the fold.
- Test all poses and Split View in the iPhone Duo simulator (Device Hub, Xcode 27.1).

## 5. Deferred — new-feature territory

- Live Activity / Dynamic Island for an in-progress game (iPhone 18 Pro three-slot island).
- Home Screen / StandBy widgets, App Intents / Siri ("record a round"), Apple Watch.
- A two-pane regular-width layout that shows *new* information on the Duo inner display or
  iPad (e.g., per-round history beside the standings) — HIG's "additional level of
  hierarchy"; it would be new UI.
- Duo dual-display extras (outer display facing other players), Apple Pencil input.

## 6. Considered and not included

- **Allowing landscape on standard iPhones.** Orientation is now only a preference and
  standard iPhones (and the Duo outer display) still honor the portrait lock. Keeping it
  avoids accidental mid-round rotation at the table. Worth revisiting after R3 lands,
  since the layouts will then support it.
- **Swift 6 language mode.** Not required (Swift 5 mode still supported by Swift 6.4).
- **Raising the deployment target.** iOS 17 is still supported; new APIs are gated with
  `#available`.
- **Glass button styles for the primary buttons.** The brand indigo button is part of the
  identity and sits in content, not in a bar; the Designer may revisit, but not required.

## 7. Unverifiable or conflicting

- iPhone Duo point sizes and aspect ratio — not published by Apple.
- Exact April 2027 date for the 27 SDK requirement — Apple says only "Starting April 2027".
- Accessibility Nutrition Label enforcement date — none announced.
- How iOS 27 renders legacy PNG app icons — no official detail.
- Apple's `UIDesignRequiresCompatibility` doc page wording — page body did not load;
  behavior corroborated by third parties only (no impact here).
- Tech talk 111461 says the inner display "doesn't honor your supported interface
  orientations" and also that iPhone Duo "respects your supported interface orientations,
  but your app will scale on the inner display" — treat layouts as needing to work in any
  aspect ratio either way.
- The `xcode-27` runner image is **public preview** (its Xcode path is named
  "Release Candidate", build 27A266a = the GA build number).
- Xcode 27.1 beta is not installed locally, so the iPhone Duo simulator isn't available
  on this Mac today.
