# Listing copy — Scorekeeper for Skyjo 1.7.1

The exact text to enter in App Store Connect, English (U.S.). Copy each block as it stands.
Source: the approved design (`design-refinement.md` and the "Text" section of `design.html`).
Character counts were measured on the text below.

## Change now, on the live 1.7 page (no new version needed)

### Promotional text (145 / 170 characters)

```
Keep score for Skyjo without the paper. Tap in each round, see who's winning, and the doubling rule is handled for you. Free, no ads, no account.
```

## Change with version 1.7.1

### What's New in This Version (112 characters)

```
Turn your iPhone sideways and the scoreboard turns with it. New App Store screenshots too, including iPhone Duo.
```

## Unchanged: leave these exactly as they are

- **App name:** "Scorekeeper for Skyjo". Unchanged.
- **Subtitle:** "A simple Skyjo score tracker" (28 / 30). **Unchanged.**
- **Keywords:** `skyjo,score,keeper,tracker,card game,score pad,tally,round tracker` (66 / 100 bytes). **Unchanged.**
- **Description:** **Unchanged.** Do not edit the current App Store Connect text. It is reproduced here only so
  the record is complete:

  ```
  A simple scorekeeping app for Skyjo that just works. Truly free, with no annoying ads or in-app purchases.

  Set up a game with 2 to 8 players, enter each round's scores, and let the app do the rest. Running totals update instantly after every round, the current standings are always visible, and the doubling rule is applied automatically based on who ended the round.

  Features:

  - Supports 2-8 players
  - Live standings updated after every round
  - Automatic doubling rule: only triggers when the round-ender has a positive score that isn't the lowest
  - Undo the last round if a score was entered wrong
  - Game ends automatically when any player reaches 100 points
  - Tiebreakers resolved by last-round score
  - Simple, fast, and out of the way
  - Free forever. No ads. No account. No tracking. No data collected. No internet connection required. Enjoy!

  This app is not affiliated with Skyjo or its creator in any way. I just really like the game of Skyjo.
  ```

## Product page header line (in the header image, Asset Library)

```
Keep score. See who's winning.
On iPhone, iPad and iPhone Duo
```

## Screenshot captions (already set in the images)

| # | iPhone 6.9" | iPad 13" | iPhone Duo outer | iPhone Duo inner |
|---|---|---|---|---|
| 1 | Keep score. See who's winning. — *Standings update after every round* | Keep score. See who's winning. — *Big enough for the whole table* | Keep score. See who's winning. | Keep score. See who's winning. — *Room for the whole table* (upright) |
| 2 | Tap in scores. We do the math. — *Ended the round without the lowest score? Doubled, automatically* | Tap in scores. We do the math. — *Ended the round without the lowest score? Doubled, automatically* | Tap in scores. We do the math. | Tap in scores. We do the math. (sideways) |
| 3 | The game ends at 100. Lowest score wins. | The game ends at 100. Lowest score wins. | The game ends at 100. Lowest score wins. | The game ends at 100. Lowest score wins. (upright) |
| 4 | 2 to 8 players. Ready in seconds. | 2 to 8 players. Ready in seconds. | 2 to 8 players. Ready in seconds. | 2 to 8 players. Ready in seconds. (sideways) |
| 5 | Free. No ads. No account. — *Dark mode too* | — | — | — |

Sublines are in italics above. In the images the apostrophe is the typographic one (who’s).

## Upload order

Standings first in every set, then score entry, final standings, setup (and the dark-mode shot
last on iPhone), matching the file numbers in each folder:

| App Store Connect slot | Folder | Files |
|---|---|---|
| iPhone 6.9" Display | `iphone-6.9-1320x2868/` | 01 to 05 |
| iPad 13" Display | `ipad-13-2064x2752/` | 01 to 04 |
| iPhone Duo (by hand; the API has no Duo display type) | `iphone-duo-outer-1398x2034/` | 01 to 04 |
| iPhone Duo (by hand) | `iphone-duo-inner/` | 01 to 04 (two upright 2007×2853, two sideways 2853×2007) |
| Product page header (Asset Library) | `header/` | `product-page-header-3840x1646.png`, or the alternative in `header/alternative-fitted-to-apple-safe-area/` (see the PR's notes) |

Whether one Duo set can mix outer and inner sizes is unconfirmed (change brief). Upload what App
Store Connect accepts, then check the page in its preview tool (iPhone Duo, dark mode) before
submitting.
