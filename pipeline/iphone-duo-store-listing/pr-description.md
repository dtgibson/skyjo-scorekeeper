## iPhone Duo Store Listing (1.7.1, build 12)

### What this does
Lets iPhone rotate to landscape (portrait plus landscape left and right, no upside-down), so an
open iPhone Duo held sideways gets the full inner display and its two-page layout. It also bumps
the app to 1.7.1 (build 12) and adds a new App Store product page: captioned screenshot sets for
iPhone 6.9", iPad 13" and both iPhone Duo displays, a product page header, and the new listing
text. Submitting the Duo screenshots is what earns the Made for iPhone Duo badge.

**In the app:** one build setting. `INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone` goes
from `UIInterfaceOrientationPortrait` to `UIInterfaceOrientationPortrait
UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight` (Debug and Release).
iPad already allowed every orientation and is unchanged. No Swift, string catalog or CI change:
the layouts already adapt to the space they're given.

**Version:** `MARKETING_VERSION` 1.7 → 1.7.1 and `CURRENT_PROJECT_VERSION` 11 → 12 in the app
target's Debug and Release configurations. The test target keeps its own 1.0 (1), as in every
earlier bump.

**Store assets** (`pipeline/iphone-duo-store-listing/store-assets/`):

| Folder | Files | Size |
|---|---|---|
| `iphone-6.9-1320x2868/` | 5: standings, score entry, final standings, setup, standings (dark) | 1320×2868 |
| `ipad-13-2064x2752/` | 4: standings, score entry (side by side), final standings, setup | 2064×2752 |
| `iphone-duo-outer-1398x2034/` | 4: the same four, closed phone | 1398×2034 |
| `iphone-duo-inner/` | 4: standings upright, score entry sideways, final standings upright, setup sideways | 2007×2853 / 2853×2007 |
| `header/` | product page header, plus an alternative (see notes) | 3840×1646 |
| `listing-copy.md` | promotional text, What's New, header line, captions, upload order; subtitle, description and keywords marked unchanged | |
| `tools/` | compositor, capture scripts, scratch-only demo-data patch, raw captures, safe-area checks | |

### How to test
1. Open `SkyjoScorekeeper/SkyjoScorekeeper.xcodeproj` in Xcode 27.1 and run on an **iPhone 17 Pro
   Max** simulator (iOS 27.0).
2. In Simulator, choose **Device → Rotate Left** (⌘←), then **Rotate Right** (⌘→). Setup, the
   standings, the score entry sheet and the final standings each re-lay out for the wide space
   and turn back when you return to portrait. Upside-down portrait doesn't rotate.
3. Open the score entry sheet, type a few scores and pick who ended the round, then rotate. The
   values stay.
4. Run on an iPad simulator: nothing changes.
5. Open the PNGs in `store-assets/`. Each set is in standings-first order; captions are as
   approved. Check sizes with
   `find store-assets -name '*.png' -not -path '*/tools/*' -exec sips -g pixelWidth -g pixelHeight -g hasAlpha {} \;`.
6. Before submitting: upload in App Store Connect (the Duo sets by hand; the API has no Duo
   display type) and check the page in the preview tool, including iPhone Duo in dark mode.

### Verification
What I ran and saw:

- **Build:** `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild build -project
  SkyjoScorekeeper/SkyjoScorekeeper.xcodeproj -scheme SkyjoScorekeeper -destination
  "platform=iOS Simulator,OS=latest,name=iPhone 17" CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
  CODE_SIGNING_ALLOWED=NO`: `** BUILD SUCCEEDED **`, no warnings.
- **Tests:** the same destination with `xcodebuild test`: `** TEST SUCCEEDED **`, 74 of 74
  passed (iPhone 17, iOS 27.0, Xcode 27.1). No tests added; this is a settings, version and
  asset change.
- **Built Info.plist:** `UISupportedInterfaceOrientations~iphone` = Portrait, LandscapeLeft,
  LandscapeRight; `CFBundleShortVersionString` 1.7.1; `CFBundleVersion` 12; `DTSDKName`
  iphonesimulator27.1; `DTXcode` 2710.
- **Not checked by me:** rotating on a standard iPhone at runtime. The simulator has no
  command-line rotation, so steps 2 and 3 above are for the Tester.

How the screenshots were captured (per CLAUDE.md, every override is listed here):

- **Build:** a scratch copy of this branch with launch hooks for the demo game (the May 2026
  family: Shawn, Mike, David, Elena, Phoebe). The patch is
  `store-assets/tools/capture/demo-hooks.patch`, and the shipped source doesn't contain it.
  The scratch build has **the shipped Info.plist settings, landscape on iPhone included**, with
  no orientation override.
- **Simulators:** iPhone 17 Pro Max (iOS 27.0), iPad Pro 13-inch M5 (iOS 27.0), iPhone Duo (iOS
  27.1). Status bar overridden to 9:41, full battery, three Wi-Fi bars, signal bars; 12-hour
  clock forced (the simulators default to 24-hour, which showed "09:41").
- **iPhone, iPad, Duo outer:** plain device screenshots. Duo outer is the closed phone's outer
  display (`--display=1`).
- **Duo inner, upright (shots 1 and 3):** `devicectl device appResize` at **669×951pt**, which
  puts the app in an exact-size window with no fold. These two screens use the tall layout
  whichever way a fold runs, so the content is what the shipped code draws. **No status bar**
  in that window. **Undo sits about 144pt in from the right edge** in shot 1, because the
  simulator copies the outer display's camera region into the window (602, 29, 37×37pt) and the
  system toolbar steps around it. Apple's inner-display bezel shows no camera there.
- **Duo inner, sideways (shots 2 and 4, and the Duo in the header):** **not a real pose.**
  Device Hub, the only way to set a pose, needs the Mac's screen unlocked and can't be
  scripted. Powering the outer display off from the command line shuts the simulator down.
  These come from `appResize` at **951×669pt** plus the scratch build's **stand-in 24pt fold at
  the window's centre**, fed through the app's real `AvailableSpace` reader, the same method as
  the iPhone Duo optimization build. In that build the app also ignored the outer-display
  regions the simulator copies into the window, which would otherwise push the left page down
  by up to 174pt. The real fold's width and position, and whether the system really shows the
  entry sheet as the centred card seen here, are still unconfirmed.

### Notes for reviewer
- **Header vs Apple's safe area (decision needed).** Apple's header template
  (`creative_assets-product_page_header_template-static.psd`) marks an **Art Safe Area** of
  only x 1097–2742, y 493–1153: the centre 43% × 40%. In the approved header the headline and
  the iPhone sit wholly outside it and the Duo partly outside. On narrower crops (iPhone) the
  headline is likely cut. That breaks the brief's guardrail ("key content inside each
  template's safe area"), and the mockup's note that it fits is mistaken. So `header/` has:
  - `product-page-header-3840x1646.png`: **as approved**;
  - `alternative-fitted-to-apple-safe-area/product-page-header-3840x1646-fitted.png`: the same
    composition scaled uniformly (0.45×) into Apple's safe area. It is **not designed or
    approved**, just a ready option.

  `tools/checks/` shows both with Apple's box drawn on. The header goes in the Asset Library, so
  either can be tried in the preview tool and swapped later without a new version.
- **Where I followed the mockup over the spec text** (the spec says the rendered mockup wins):
  - The header headline wraps to "Keep score. / See who's / winning." in its 28% text block.
  - The radial glow behind the header devices is kept.
  - No screen shadow on framed shots (bezels are never shadowed).
  - The iPhone Duo upright shots overshoot the spec's 115px bottom margin by 5px; the mockup's
    geometry is identical.
- **Score entry focus:** the first row (Shawn) has the focus ring, not Phoebe as in the mockup.
  With the last row focused, the app scrolls it to the centre and pushes "Round 1 scores" off
  the top. Shawn is where the sheet opens, so it's a real state, and the label stays in view.
- **Status bar:** `--batteryState discharging --batteryLevel 100`, a full battery with no
  charging bolt. The brief's `charged` draws a bolt.
- **iPad shots** show iPadOS's small window-resize arc in the bottom-right corner of the
  screen. The iPad simulator runs in Windowed Apps mode and the mode can't be changed from the
  command line. It's genuine system UI.
- **Bezels:** Apple's full-resolution Design Resources originals (iPhone 18 Pro Max Black,
  iPad Pro 13" Silver, iPhone Duo Star White), the same art as the mockup's 900px copies. The
  licence forbids redistributing the bezel files on their own, so they are **not** in the
  repo; `tools/fetch-bezels.sh` downloads them. For the same reason,
  `mockup-assets/bezels/` (the Designer's extracts) **should not be committed** to this public
  repo.
- **Repo size:** `store-assets/` is about 37 MB (17 screenshots and 2 headers ≈ 26 MB, raw
  captures 4.7 MB).
- **Copy counts** (measured): promotional text 145/170, What's New 112, subtitle 28/30,
  keywords 66/100 bytes. The mockup's counters showed 113, 29 and 68 for the same text.
- **Informational:** with five players on a standard iPhone held sideways, the standings, setup
  and final lists show about four rows and scroll. The user accepted this at design review.
- **Still open from 1.7:** real iPhone Duo poses (open, half-open, propped, flipped) haven't been
  seen. Retake the four inner-display shots on a real device or in Device Hub when one is
  available (`store-assets/tools/README.md`).
- **Decision reversal for the Chronicler:** iPhone is no longer portrait-only (reverses
  2026-10-23 and 2026-09-26); see `decisions.md`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
