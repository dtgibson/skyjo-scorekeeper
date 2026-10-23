# Roadmap

## Up Next

1. **Check iPhone Duo on a real device** — 1.7 shipped without any real pose being seen. On a device (or Device Hub with the Mac unlocked): does the portrait-only app get the full open display or a ~501pt window with ~238pt pages; does Undo clear the inner camera; do the pages hold half-open and flipped; how wide is the real fold. If the window is narrow, allowing landscape on iPhone is the likely fix.
2. **CI hardening** — declare `permissions: contents: read` (the token is read-only today only by a repo setting, and the repo is public), pin `actions/checkout` to a commit SHA, set `persist-credentials: false`, and drop the `DEVELOPER_DIR` line once the stable `xcode-27` image defaults to Xcode 27.1.

---

## On the Horizon

- **iPhone Duo App Store screenshots** — reportedly required from April 2027, but no source was found; check Apple's screenshot specifications before acting.
- **Design system reference** — consolidate `brand.md` and the iOS 27 and iPhone Duo design refinements into one design-system file for future design passes.
- **Layered app icon** — rebuild the icon in Icon Composer 2 for real glass depth (current icon kept for now).
- **Landscape on standard iPhones** — the layouts now support it; left out to avoid accidental mid-round rotation. Revisit with the iPhone Duo device check.
- **System integrations** — Home Screen / StandBy widgets, a Live Activity for an in-progress game, App Intents / Siri ("record a round").
- **Swift 6 language mode** — not required yet; Swift 5 mode is still supported.

---

## Shipped

**Features shipped:** 11

**Last shipped:** iPhone Duo Optimization (1.7, submitted 2026-10-23, releases on App Review approval) — On an open iPhone Duo each screen splits into two pages around the fold so no button sits on it, and CI now builds on Xcode 27.1.

**Previously:** iOS 27 Platform Readiness (2026-09-26) — The app builds on Xcode 27 and works in any window shape (resizable iPad windows, iPhone Mirroring, iPhone Duo), with a system toolbar on the scoreboard and two open windows kept in sync.
