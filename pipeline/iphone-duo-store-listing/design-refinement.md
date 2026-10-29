# Design Refinement — iPhone Duo Store Listing

Approved 2026-10-29 after eight rounds. The mockup is `pipeline/iphone-duo-store-listing/design.html`
(assets in `mockup-assets/`); this document is the spec The Engineer builds the store assets from.
Where the two disagree, the mockup's rendered values win and this file should be corrected.

## Visual Direction
Every screenshot is the real app, light mode on a soft indigo gradient, inside Apple's own product
bezel used as-is, with one short caption above it in the app's typeface and brand indigo. The sets
feel like one family across iPhone, iPad and both iPhone Duo displays: same people, same scores, same
captions, the bezel alone saying which device you are looking at. Nothing is drawn that the shopper
would not see on the device: no fold, no card art, no badge.

## Shared composition (all four sets)

- **Background:** `linear-gradient(180deg, #EEF0FF 0%, #E3E2F8 55%, #D9D7F4 100%)` with two soft
  glows: `radial-gradient(60% 32% at 50% 24%, rgba(91,80,214,.22), transparent 70%)` and
  `radial-gradient(70% 40% at 50% 110%, rgba(55,48,163,.18), transparent 70%)`.
  Dark variant (iPhone shot 5 only): `linear-gradient(180deg, #1B1946 0%, #131238 55%, #0B0A24 100%)`,
  glows `rgba(140,131,240,.28)` and `rgba(91,80,214,.25)` at the same positions.
- **Caption:** SF Rounded (SF Pro Rounded), weight 800, letter-spacing −0.02em, line-height 1.08,
  centred, text-wrap balanced, colour `#3730A3`; on the dark shot `#EDEBFF`. Optional subline on its
  own line below: weight 600, letter-spacing 0, colour `#5B50D6` at 92% opacity (dark: `#B3ACF5`),
  22 px (at export scale) below the headline. Two caption lines at most; sublines are the first thing
  to drop if anything feels tight.
- **Screen + bezel:** the capture is placed at the width below, corners clipped to the device radius,
  and Apple's bezel PNG is overlaid so its display cut-out exactly covers the capture. Bezels are not
  shadowed, tilted, recoloured or cropped. The soft drop shadow sits on the screen stack:
  `0 40px 90px -20px rgba(30,24,110,.45)` plus `0 6px 14px rgba(30,24,110,.12)` at export scale.
- **Safe zone:** keep the caption and the whole device inside the margins listed per set (`m`
  horizontally, `mTop` top and bottom). The mockup's "Safe-zone guides" toggle draws them.
- **Export:** PNG, sRGB, no alpha, exact pixel size, checked with `sips -g pixelWidth -g pixelHeight`.

| Set | Image px | Capture pt | Bezel file (`mockup-assets/bezels/`) | Screen width px | Screen top px | Screen radius | Caption top / size / subline px | Margins m / mTop px |
|---|---|---|---|---|---|---|---|---|
| iPhone 6.9" | 1320 × 2868 | 440 × 956 | `iphone-18-pro-max-portrait.png` | 980 | 560 | 70 | 170 / 92 / 44 | 80 / 115 |
| iPad 13" | 2064 × 2752 | 1032 × 1376 | `ipad-pro-13-portrait.png` | 1480 | 560 | 60 | 150 / 104 / 48 | 124 / 110 |
| Duo outer | 1398 × 2034 | 466 × 678 | `duo-outer-closed.png` | 990 | 430 | 64 | 120 / 84 / 40 | 84 / 82 |
| Duo inner, upright | 2007 × 2853 | 669 × 951 | `duo-inner-portrait.png` | 1460 | 580 | 80 | 170 / 104 / 48 | 120 / 115 |
| Duo inner, sideways | 2853 × 2007 | 951 × 669 | `duo-inner-landscape.png` | 2000 | 390 | 80 | 110 / 92 / 44 | 160 / 80 |

Bezel cut-out geometry (fraction of the bezel image: left, top, width, height) as the mockup uses it:
iPhone .0510/.0220/.8980/.9560 · iPad .0513/.0413/.8974/.9173 · Duo outer .0559/.0369/.8882/.9262 ·
Duo inner portrait .0534/.0388/.8932/.9224 · Duo inner landscape .0388/.0534/.9224/.8932.

## Demo data (locked: the May 2026 family)
Players in setup order: **Shawn, Mike, David, Elena, Phoebe** (five players, "5 players ready").
Avatar colours by position index via `Theme.playerColor(at:)`.
- **Entry sheet:** Round 1 scores Shawn 5, Mike 12, David 7, Elena 8, Phoebe 10; David ended the
  round, so his row shows the doubling preview ×2 → 14. Button "Confirm Round 1".
- **Standings:** heading into Round 2: Shawn 5, Elena 8, Phoebe 10, Mike 12, David 14. Button
  "Enter Round 2 Scores".
- **Final standings:** 6 rounds played, Shawn wins on 80, Phoebe 90, Elena 96, Mike 100 (bust),
  David 119. "Shawn Wins!", "6 rounds played", buttons "New Game — Same Players" and "Start Fresh".
- Status bar 9:41, full battery, three Wi-Fi bars. Never the Easter egg. Light mode everywhere except
  iPhone shot 5.

## Screenshot sets

Captions below are exact and locked. A `/` marks the line break in the headline where the mockup
breaks it; a sideways Duo caption is one line.

### iPhone 6.9" — 1320 × 2868, five shots (Apple scales to the 6.3" class)
| # | Screen | Data | Caption | Subline |
|---|---|---|---|---|
| 1 | Standings | Round 2 standings | "Keep score. / See who's winning." | "Standings update after every round" |
| 2 | Entry sheet | Round 1 scores, David ×2 → 14 | "Tap in scores. / We do the math." | "Ended the round without the lowest score? Doubled, automatically" |
| 3 | Final standings | Shawn wins, 6 rounds | "The game ends at 100. / Lowest score wins." | — |
| 4 | Setup | five players | "2 to 8 players. Ready in seconds." | — |
| 5 | Standings, **dark mode** | Round 2 standings | "Free. No ads. No account." | "Dark mode too" |

Orientation: upright. Simulator: iPhone 17 Pro Max (or 18 Pro Max), iOS 27.0, tall layout.

### iPad 13" — 2064 × 2752, four shots
| # | Screen | Data | Caption | Subline |
|---|---|---|---|---|
| 1 | Standings | Round 2 standings | "Keep score. / See who's winning." | "Big enough for the whole table" |
| 2 | Entry sheet, side-by-side layout (scores left, who-ended and numpad right) | Round 1, David ×2 → 14 | "Tap in scores. / We do the math." | "Ended the round without the lowest score? Doubled, automatically" |
| 3 | Final standings | Shawn wins | "The game ends at 100. / Lowest score wins." | — |
| 4 | Setup | five players | "2 to 8 players. Ready in seconds." | — |

Orientation: portrait. Simulator: iPad Pro 13-inch (M5), iOS 27.0. The wide entry sheet is what the
app already shows at this width; no override.

### iPhone Duo, outer display — 1398 × 2034, four shots
| # | Screen | Data | Caption |
|---|---|---|---|
| 1 | Standings | Round 2 standings | "Keep score. / See who's winning." |
| 2 | Entry sheet | Round 1, David ×2 → 14 | "Tap in scores. / We do the math." |
| 3 | Final standings | Shawn wins | "The game ends at 100. / Lowest score wins." |
| 4 | Setup | five players | "2 to 8 players. Ready in seconds." |

No sublines. Orientation: upright (closed phone). iPhone Duo simulator, iOS 27.1, closed; capture the
outer display by id (`simctl io <id> screenshot --display=<outer>`), otherwise you get the dark inner
display.

### iPhone Duo, inner display — four shots, orientation per shot (user decision 2026-10-29)
| # | Screen | Orientation | Image px | Bezel | Caption | Subline |
|---|---|---|---|---|---|---|
| 1 | Standings, tall layout | **Upright** | 2007 × 2853 | `duo-inner-portrait.png` | "Keep score. / See who's winning." | "Room for the whole table" |
| 2 | Entry sheet, two pages: Round 1 scores on the left page, "Who ended the round?" chips, numpad and Confirm on the right | **Sideways** | 2853 × 2007 | `duo-inner-landscape.png` | "Tap in scores. We do the math." | — |
| 3 | Final standings, tall layout | **Upright** | 2007 × 2853 | `duo-inner-portrait.png` | "The game ends at 100. / Lowest score wins." | — |
| 4 | Setup, two pages: players list on the left page, title, Start Game and "5 players ready" on the right | **Sideways** | 2853 × 2007 | `duo-inner-landscape.png` | "2 to 8 players. Ready in seconds." | — |

Safe-area notes for this set: nothing of the app sits on the fold in the sideways shots (list on the
left page, controls on the right, the system sheet uses the fold as its divider); no crease is drawn,
the open display is one clean rectangle; the upright shots show the tall layout with the list
crossing where the fold would be and every button clear of it. Captions stay inside the 160 / 80 px
(sideways) and 120 / 115 px (upright) margins. Upload this set by hand in App Store Connect (the API
has no Duo display type) and check it in the preview tool in dark mode.

## Product page header (3840 × 1646, 21:9, iOS 27 and later)
- **Background:** `linear-gradient(100deg, #EEF0FF 0%, #E2E0F8 50%, #D4D1F2 100%)`.
- **Text block (left):** starts at 7% from the left edge, 28% wide, vertically centred, inside the
  left 35%. Headline "Keep score. / See who's winning." SF Rounded weight 800, letter-spacing −0.025em,
  line-height 1.02, about 177 px tall at full size (4.6% of the width), colour `#3730A3`. Below it,
  half a line down, the header line **"On iPhone, iPad and iPhone Duo"** at 0.42× the headline size,
  weight 600, colour `#5B50D6`.
- **Devices (right):** two, inside the right 57% (from 40% to 97% of the width), bottoms aligned at
  8% above the lower edge, not overlapping. Left: the open iPhone Duo held sideways in
  `duo-inner-landscape.png`, showing the two-page standings (Round 2 standings on the left page,
  "Round 2" heading and "Enter Round 2 Scores" on the right), silhouette height about 1080 px. Right,
  starting at 71% across the device region: iPhone 18 Pro Max bezel showing the Round 2 standings,
  silhouette height about 1300 px, in front. Same screen shadow as the screenshots.
- No iPad in the header (three bezels made every one too small), no card art, logo, badge, price or
  URL. Export from Apple's header template so the safe area is Apple's: sRGB, no alpha. Upload to the
  Asset Library (no new version needed).

## Listing copy (exact, final)
- **App name:** "Scorekeeper for Skyjo" — unchanged.
- **Subtitle:** "A simple Skyjo score tracker" — **unchanged.**
- **Keywords:** `skyjo,score,keeper,tracker,card game,score pad,tally,round tracker` — **unchanged.**
- **Description:** **unchanged**, the current App Store Connect text as reproduced in `design.html`
  (section "Text"). Do not edit it.
- **Promotional text (170 max, 145 used; can go live on 1.7 now):**
  > Keep score for Skyjo without the paper. Tap in each round, see who's winning, and the doubling rule is handled for you. Free, no ads, no account.
- **What's New, 1.7.1 (locked option 2):**
  > Turn your iPhone sideways and the scoreboard turns with it. New App Store screenshots too, including iPhone Duo.
- **Header line (product page header):** "Keep score. See who's winning." over "On iPhone, iPad and iPhone Duo".
- **Captions per shot:** as tabled above. In full: "Keep score. See who's winning." · "Tap in scores.
  We do the math." · "The game ends at 100. Lowest score wins." · "2 to 8 players. Ready in seconds." ·
  "Free. No ads. No account." Sublines: "Standings update after every round" · "Ended the round
  without the lowest score? Doubled, automatically" · "Big enough for the whole table" · "Room for the
  whole table" · "Dark mode too".

Voice: warm and plain, the `SUPPORT.md` register. No development or platform vocabulary (no fold,
crease, layout, landscape-mode), no "called Skyjo", no Apple badge names in images. The doubling rule
is always phrased as "the player who ends the round without the lowest score".

## Typography and colour tokens
- **Type:** SF Rounded throughout (`ui-rounded` / "SF Pro Rounded"), matching
  `Font.system(..., design: .rounded)` in the app. Caption weight 800, subline 600. SF Rounded has no
  italic; emphasis is weight only.
- **Brand:** `#3730A3` (`Theme.brand`); light accent `#5B50D6` (sublines, header line); ink on the
  indigo scale `#2A2480`. If a high-contrast variant is ever needed for a caption, use the
  `Theme.brandHighContrast` value from `Theme.swift`; the store assets as specified do not need it.
- **Neutrals:** page gradients above; dark-shot caption `#EDEBFF`, dark subline `#B3ACF5`.
- **Radii:** screen corner clip 70 / 60 / 64 / 80 px per set as tabled (device radius at export scale).
- **Player colours** come from the app itself (`Theme.playerColor(at:)` by position), never recoloured.

## Capture notes for The Engineer
- Follow the **Screenshot capture plan** in `change-brief.md` (simulators, status-bar override,
  `DEVELOPER_DIR` prefix, demo-data hooks in a scratch copy only, `sips` size and no-alpha check,
  App Store Connect preview tool before submitting).
- **Version:** 1.7.1, build 12, built with Xcode 27.1.
- **Info.plist (scope amendment 2026-10-27):** enable landscape on iPhone — portrait plus landscape
  left and right, **no upside-down**. No Swift changes expected.
- **Duo inner orientation per shot:** 1 upright · 2 sideways · 3 upright · 4 sideways. Upright
  captures are 669 × 951 pt (Device Hub open pose with the fold side to side if the Mac is unlocked,
  otherwise `devicectl device appResize` at 669 × 951). Sideways captures are 951 × 669 pt from the
  1.7.1 build with landscape enabled; the two-page layout only appears when the system reports the
  fold, so prefer a real open pose in Device Hub. If a stand-in fold scratch build is the only route
  (as the last Tester used), say so in the PR's Verification section per `CLAUDE.md`.
- **Order of upload:** standings first in every set; the Duo inner set is uploaded by hand.
- **Informational, not a requirement:** on a standard iPhone turned sideways (iPhone 17 Pro Max,
  956 × 440 pt) with five players, the standings, setup list and final table show about four rows and
  scroll, with the main button pinned below; the entry sheet fits best. The user reviewed these
  previews and accepted them as they stand. No row-height relief is required; worth a look on a real
  phone before 1.7.1 ships, and the Tester should cover landscape per the change brief.
- **Linter notes carried over from the mockup:** three `untinted-black` notes in `design.html`
  (`.scr.dark` background, the win-screen dark gradient, the Dynamic Island). All deliberate: they
  reproduce iOS true-black dark mode and the hardware cutout as the real app and device render them.

## Motion Spec
The deliverables are static images and store copy; there is no motion to specify.

## Content Notes
- Real UI only (Review Guideline 2.3.3): every pixel inside a bezel is a capture of the shipping app
  with the demo data above. No retouching beyond placing it on the gradient.
- Store name stays "Scorekeeper for Skyjo"; the in-app title stays "Skyjo Scorekeeper" on the setup
  screen. Do not introduce a third name.
- No app preview video this pass (follow-up logged). No search-result asset, custom product pages or
  store localization this pass.
- Captions are one short phrase that adds to the picture rather than describing it; they never
  mention the device, the fold or how the app was built.
