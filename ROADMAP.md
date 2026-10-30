# Roadmap

## Up Next

1. **Check the live page once 1.7.1 is approved** — confirm 1.7.1 reaches Ready for Sale (if rejected, read the resolution notes and route the fix), the header line sits fully in view on an iPhone, and the Made for iPhone Duo badge appears (Apple hasn't said how soon). Then delete the old, unplaced header image from the Asset Library.
2. **Check iPhone Duo on a real device** — no real pose has been seen yet. On a device (or Device Hub with the Mac unlocked): does the app get the full open display in landscape; does Undo clear the inner camera; do the pages hold half-open and flipped; how wide is the real fold. Then retake the four inner-display store screenshots (the two sideways ones use a stand-in fold), and only after that consider Apple's optional "optimized for iPhone Duo" featuring nomination.
3. **CI hardening** — declare `permissions: contents: read` (the token is read-only today only by a repo setting, and the repo is public), pin `actions/checkout` to a commit SHA, set `persist-credentials: false`, and drop the `DEVELOPER_DIR` line once the stable `xcode-27` image defaults to Xcode 27.1.

---

## On the Horizon

- **Store listing in more languages** — the app ships 36 languages but the App Store page is English (US) only; localize the listing text and screenshot captions.
- **Sideways iPhone with many players** — with five or more players about four rows show, and the fifth "who ended the round" chip sits behind a scroll in its block, easy to miss. Consider tighter rows in the short layout.
- **App preview video** — optional; skipped for 1.7.1.
- **Design system reference** — consolidate `brand.md` and the iOS 27 and iPhone Duo design refinements into one design-system file for future design passes.
- **Layered app icon** — rebuild the icon in Icon Composer 2 for real glass depth (current icon kept for now).
- **System integrations** — Home Screen / StandBy widgets, a Live Activity for an in-progress game, App Intents / Siri ("record a round").
- **Swift 6 language mode** — not required yet; Swift 5 mode is still supported.

---

## Shipped

**Features shipped:** 12

**Last shipped:** iPhone Duo Store Listing (1.7.1, submitted 2026-10-29, releases on App Review approval) — iPhone now turns to landscape, and the App Store page gets new captioned screenshots for iPhone, iPad and iPhone Duo, a product page header and promotional text, which should earn the Made for iPhone Duo badge.

**Previously:** iPhone Duo Optimization (1.7, 2026-10-23) — On an open iPhone Duo each screen splits into two pages around the fold so no button sits on it, and CI now builds on Xcode 27.1.
