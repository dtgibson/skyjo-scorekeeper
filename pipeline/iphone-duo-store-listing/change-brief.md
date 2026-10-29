# Change Brief — iPhone Duo Store Listing

## What is changing
Refresh the App Store product page for Scorekeeper for Skyjo and earn Apple's **Made for iPhone
Duo** badge (the badge's real name; "Built for iPhone Duo" isn't used anywhere). Apple shows it once
iPhone Duo screenshots are submitted. The live 1.7 page was built with Xcode 27.1 and shows no badge
today. This pass captures new screenshots of the current app for iPhone, iPad and both iPhone Duo
displays, designs them as one set with short captions, rewrites the listing copy, and adds a product
page header. Screenshots, subtitle, description and keywords can only change with a new version, so
the listing ships as **1.7.1 (build 12)**: the same app code with a new product page. Promotional text
can go live on 1.7 straight away.

## Why now
- iPhone Duo launched 2026-10-23 with editorial collections and a badge for optimized apps. 1.7 has
  the work behind it (now live, READY_FOR_SALE) but no badge.
- Duo screenshots become mandatory from April 2027 for apps built on the iOS 27.1 SDK. This app is.
- The store screenshots date from 13 and 16 May 2026 (4 × iPhone 6.9", 4 × iPad 13"). They show the
  app before the numpad (June 2), before the "Nobody" chip was removed (June 6), before the iOS 27
  toolbar and adaptive layouts (Sept 26) and before the Duo two-page layouts (Oct 23). They're raw
  simulator captures with no captions.
- Promotional text is empty, there are no app previews, and the keywords repeat words already in the
  app name (Apple says not to).

## Badge requirements (sourced)
- **Trigger:** "When you submit iPhone Duo screenshots in App Store Connect, your App Store product
  page will display a badge…" ([1], [2], [3]). 9to5Mac's copy of the 2026-10-05 post quoted "When you
  build or recompile using Xcode 27.1…" instead ([6]). Apple's live pages now say screenshots, and 1.7
  meets the build condition with no badge showing ([7]), which fits that reading. We do both.
- **Optimized** means built with the iOS 27.1 SDK or later ([2]). 1.7 is (`DTSDKName iphoneos27.1`).
- **Sizes** ([3]): outer display 1398×2034 / 2034×1398; inner display 2007×2853 / 2853×2007. 1 to 10
  per set, PNG or JPEG, no alpha. Duo is its own entry; other iPhone sizes are not scaled into it.
- **Deadline** ([3]): "Starting in April 2027, screenshots will be required for any app using the iOS
  27.1 SDK or later." The news post says "any apps or games submitted" ([1]). Applies to us either way.
- **App previews** are optional ([4]): Duo accepts 886×1920 / 1920×886, 15 to 30 seconds, up to 3.
- **Nothing else is published:** no Info.plist key, capability, checkbox, orientation rule or separate
  review for the badge ([1], [2], [3]).
- **Unconfirmed:** whether portrait-only apps qualify (nothing says they don't); whether one Duo set
  can mix outer and inner sizes; how the store chooses shots per display; how soon the badge appears
  after approval; what the badge looks like (Apple hasn't shown it). The published App Store Connect
  API list of screenshot display types has no Duo value (checked 2026-10-27, [8]), so plan to upload
  the Duo set by hand in App Store Connect.
- **Optional:** a featuring nomination saying the app is optimized for iPhone Duo, "including support
  for all device poses" ([2]). Only after real poses have been checked.

## What the app already meets, and the gaps
Already met: built on the 27.1 SDK; two-page fold layouts; closed (outer) display; none of the
patterns Apple's "Prepare" page asks you to remove (`UIScreen.main`, orientation or idiom checks);
Accessibility Nutrition Labels published for iPhone and iPad.
1. **No iPhone Duo screenshots.** The only hard gap for the badge.
2. **Inner display, landscape (the two-page layout).** In the simulator the shipped portrait-only app
   gets a 501×669pt window on the open 951×669pt display, so a 2853×2007 capture would show a narrow
   window with empty space around it. The last build's two-page screenshots came from a scratch build
   with landscape switched on and a stand-in fold. Honest landscape inner shots need either a real
   device (or Device Hub) showing the app gets the full display, or allowing landscape on iPhone.
   Inner **portrait** (open, turned so the fold runs side to side, 669×951pt → 2007×2853) works with
   the shipped app today.
3. **Real poses are still unchecked.** Device Hub needs the Mac's screen unlocked.

## Store page inventory
| Element | Today | Plan | New version? |
|---|---|---|---|
| App name (30) | "Scorekeeper for Skyjo" | Keep. Approved, and the Skyjo name is trademark-sensitive | — |
| Subtitle (30) | "A simple Skyjo score tracker" | Refine for clarity and search | Yes |
| Promotional text (170) | Empty | Write it, mention iPhone Duo | No, edit live now |
| Description (4000) | 1.5-era feature list | Refresh: iPhone Duo, iPad, any window, 36 languages, accessibility. Keep the not-affiliated line | Yes |
| Keywords (100 bytes) | `skyjo,score,keeper,tracker,card game,score pad,tally,round tracker` | Drop words already in the name, add new terms | Yes |
| What's New | 1.7 Duo note | Short 1.7.1 note | Yes |
| iPhone screenshots | 4 × 1320×2868, May | New captioned 6.9" set (scales down to the required 6.3" class) | Yes |
| iPad screenshots | 4 × 2048×2732, May | New 13" set at 2064×2752 | Yes |
| iPhone Duo screenshots | None | New set: outer, plus inner portrait | Yes |
| App previews | None | Optional single iPhone preview; The Designer decides | Yes |
| Product page header (21:9, 3840×1646) | None | One image (iOS 27 and later) | No, Asset Library |
| Search result asset (3:2) | None | Skip; the screenshots show real UI there | — |
| Custom product pages, page tests, in-app events | None | Skip: no ads, no events | — |
| Accessibility labels, age rating 4+, categories (Games: Card, Family; Utilities), support URL | Set | Keep | — |
| Marketing URL | Empty | Optional | No |
| App icon | From the binary | Keep; Icon Composer rebuild stays on the roadmap | — |
| Store localization | English (US) only; the app ships 36 languages | Not this pass; follow-up | — |

Note for copy: the store name is "Scorekeeper for Skyjo" but the home-screen name and `SUPPORT.md`
say "Score for Skyjo". Leave the names alone; just don't add a third.

## Screenshot capture plan
Use the shipped Info.plist settings (portrait lock on), demo-data hooks in a scratch copy only (as the
last Tester did), a clean status bar (`xcrun simctl status_bar <id> override --time 9:41
--batteryState charged --batteryLevel 100 --wifiBars 3`), and never the Easter egg. Prefix `xcrun`
with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.
- **iPhone 6.9":** iPhone 18 Pro Max or 17 Pro Max simulator (iOS 27.0), 1320×2868.
- **iPad 13":** iPad Pro 13-inch (M5) simulator (iOS 27.0), 2064×2752 portrait.
- **Duo outer:** iPhone Duo simulator (iOS 27.1), closed, 1398×2034. Pass the outer display's id
  (`simctl io <id> screenshot --display=<outer>`); without it you capture the dark inner display.
- **Duo inner portrait:** 2007×2853. Device Hub for a real open pose if the Mac is unlocked; otherwise
  `devicectl device appResize` at 669×951 (exact size, no fold; the tall layout is what that pose shows).
- **Duo inner landscape (two pages):** 2853×2007, only if gap 2 is resolved. Otherwise leave it out.
- Check every file with `sips -g pixelWidth -g pixelHeight` and for no alpha, then look at the page in
  App Store Connect's preview tool (iPhone Duo, dark mode) before submitting.

## Scope
Changes: new files in `pipeline/iphone-duo-store-listing/` (listing copy, screenshot PNGs, header
image, capture notes); `project.pbxproj` version 1.7.1 / build 12; App Store Connect metadata.
Unchanged: all Swift source, `Localizable.xcstrings`, CI, the app icon. **Amended 2026-10-27:** the
iPhone orientation setting changes to allow landscape (see *Scope amendment* below).
**Scope risk:** resolving gap 2 by allowing landscape on iPhone changes the Info.plist for every
iPhone and reverses the portrait-lock decision. That is the user's call (with its own testing on
standard iPhones), not something to slip in.

## User-facing impact
In the app: iPhone now rotates to landscape (amended 2026-10-27; see *Scope amendment*). The
layouts already support it; a phone tilted mid-round re-lays out and rotates back. Otherwise none. On the App Store: new screenshots, a header, new copy, and the Made for iPhone Duo
badge once the Duo set is approved. Promotional text shows right away. 1.7.1 arrives as a routine
update with nothing different inside.

## Design pass
Needed. The product page is the app's first impression, and this changes how it looks. The Designer
owns the screenshot story and order for each set (iPhone, iPad, Duo outer, Duo inner); captions, type
and colour (SF Rounded, brand indigo #3730A3); device frames or full-bleed; the 3840×1646 header;
whether an app preview earns its place; and the listing copy (subtitle, promotional text,
description, keywords, What's New) in the warm voice of `SUPPORT.md`. Guardrails: real UI only
(Review Guideline 2.3.3), no Skyjo card art or logo, no Apple badges or awards drawn into images, no
prices or URLs, key content inside each template's safe area.

## Decisions touched
- **"iPhone stays portrait-only, and 1.7 shipped before any real Duo pose was observed"** (2026-10-23)
  and **"Standard iPhones keep the portrait lock"** (2026-09-26): touched, not changed. They limit
  which inner-display screenshots are honest. Reversing them is the user's call.
- **Two-page fold layouts** (2026-10-23): shown off, unchanged.
- **CI selects Xcode 27.1 via `DEVELOPER_DIR`** (2026-10-23): kept. 1.7.1 must be built with 27.1.
- **App icon out of scope** (2026-09-26): stays out.
- **35 locales via DeepL** (2026-05-24): the store listing stays English this pass; follow-up logged.
- `CLAUDE.md` "Capture layout evidence with the shipped Info.plist settings": applies to store shots.

## What done looks like
1.7.1 (build 12, Xcode 27.1) is submitted with new iPhone, iPad and iPhone Duo screenshot sets, the
new copy and a product page header, each checked in App Store Connect's preview tool. Once approved,
the product page shows the Made for iPhone Duo badge and the new screenshots. Promotional text is live
on 1.7 before that. Every screenshot shows the app exactly as someone would see it.

## Scope amendment (2026-10-27, user decision)
The user chose to **allow landscape on iPhone** so the open iPhone Duo held sideways gets the full
display and the two-page layout, making the inner-landscape (2853×2007) screenshot honest. This
reverses the recorded decisions "iPhone stays portrait-only" (2026-10-23) and "Standard iPhones keep
the portrait lock" (2026-09-26); the Chronicler must log the reversal. Consequences for this build:
- The Engineer changes the iPhone supported-orientation setting (portrait plus both landscapes,
  no upside-down) in the project's Info.plist settings. No Swift changes expected.
- 1.7.1 is no longer code-identical to 1.7: What's New must mention landscape on iPhone.
- The Tester covers landscape on a standard iPhone simulator (status bar and home indicator on the
  sides; tall ↔ wide re-layout; entry-sheet state surviving rotation) plus the open Duo in landscape
  with the shipped settings, and the Duo inner-landscape screenshot is captured from that build.
- Store screenshots of the open Duo in landscape are now in scope (Apple's inner-open-landscape bezel).

## Sources (checked 2026-10-27)
1. Apple Developer News, "Prepare and submit your apps for iPhone Duo" (2026-10-05): https://developer.apple.com/news/?id=kkphp5qo
2. Apple, iPhone Duo "Prepare" page: https://developer.apple.com/iphone-duo/prepare/
3. App Store Connect Help, Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/
4. App Store Connect Help, App preview specifications: https://developer.apple.com/help/app-store-connect/reference/app-information/app-preview-specifications
5. Apple Newsroom, "Developers bring incredible new app experiences to iPhone Duo" (2026-10-22): https://www.apple.com/newsroom/2026/10/developers-bring-incredible-new-app-experiences-to-iphone-duo/
6. 9to5Mac (2026-10-05), earlier badge wording: https://9to5mac.com/2026/10/05/apple-invites-developers-to-submit-iphone-duo-ready-apps-to-the-app-store/
7. Live product page (1.7, no Duo badge, iPhone and iPad sets only): https://apps.apple.com/us/app/id6768505223
8. App Store Connect API, ScreenshotDisplayType: https://developer.apple.com/documentation/appstoreconnectapi/screenshotdisplaytype
9. What's new in App Store (creative assets, Asset Library, preview tool): https://developer.apple.com/app-store/whats-new/
10. Asset best practices and templates: https://developer.apple.com/app-store/asset-best-practices/
11. Creative assets specifications (header 21:9 3840×1646; search 3:2): https://developer.apple.com/help/app-store-connect/reference/app-information/creative-assets-specifications
12. Manage your App Store assets (uploads only while a version is editable): https://developer.apple.com/help/app-store-connect/manage-app-information/manage-your-app-store-assets
13. Platform version information (promotional text editable without a new version; field limits): https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
14. App information (name and subtitle, 30 characters): https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
Current listing values were read from the App Store Connect API (read-only, key QJA25M7XHM).
