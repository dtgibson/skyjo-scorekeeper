# Roadmap

## Up Next

Nothing queued — ready for the next idea.

---

## On the Horizon

- **iPhone Duo fold avoidance** — keep the pinned primary buttons out of the fold with `ReservedRegion` and test all Duo poses; needs the iOS 27.1 SDK (Xcode 27.1 final).
- **CI hardening** — declare `permissions: contents: read`, pin `actions/checkout` to a commit SHA, and set `persist-credentials: false`.
- **Layered app icon** — rebuild the icon in Icon Composer 2 for real glass depth (current icon kept for now).
- **Landscape on standard iPhones** — the layouts now support it; left out to avoid accidental mid-round rotation.
- **System integrations** — Home Screen / StandBy widgets, a Live Activity for an in-progress game, App Intents / Siri ("record a round").
- **Swift 6 language mode** — not required yet; Swift 5 mode is still supported.

---

## Shipped

**Features shipped:** 10

**Last shipped:** iOS 27 Platform Readiness (2026-09-26) — The app builds on Xcode 27 and works in any window shape (resizable iPad windows, iPhone Mirroring, iPhone Duo), with a system toolbar on the scoreboard and two open windows kept in sync.

**Previously:** App Refinement (2026-06-06) — Clearer rules microcopy, near-100 danger cues, faster score entry, and deeper VoiceOver feedback.
