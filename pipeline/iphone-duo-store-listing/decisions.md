# Decisions — iPhone Duo Store Listing

## 2026-10-27 — Allow landscape on iPhone (user decision at the Designer stage)
**Decision:** iPhone allows landscape (portrait + landscape left/right). Reverses "iPhone stays
portrait-only" (2026-10-23) and "Standard iPhones keep the portrait lock" (2026-09-26).
**Why:** The portrait lock stops the open iPhone Duo held sideways from using the two-page layout
(the simulator gives the app a 501pt window), so an honest landscape store screenshot was impossible.
The layouts already support landscape; the only cost named by the original decision was accidental
mid-round rotation, which the user accepted (Control Center rotation lock remains available).
**Scope effect:** Info.plist orientation setting changes; 1.7.1 now has an in-app change; What's New
copy updated; Tester covers standard-iPhone landscape and the Duo open landscape pose.

## 2026-10-27 — Store listing design choices (Designer rounds 1 to 5)
- Apple's iPhone Duo / iPhone / iPad bezels from Design Resources, used as-is (no shadow, tilt or crop).
  First direction was frameless; corrected after confirming Apple ships Duo bezels.
- No drawn fold or crease anywhere; the open inner display is one clean rectangle.
- Player names, scores and finishing order carried over exactly from the May 2026 screenshots
  (Shawn, Mike, David, Elena, Phoebe; Shawn wins on 80) for sentimental reasons.
- Existing subtitle, description and keywords stay unchanged. New text only where none existed:
  promotional text, What's New, captions, header line. Captions are plain shopper language with no
  development or platform vocabulary; the doubling rule is stated correctly (the player who ends the
  round without the lowest score).
- No app preview video this pass.

## 2026-10-29 — Duo inner-display orientation per shot, and sideways-iPhone previews accepted (user decisions, Designer round 8)
- **Orientation per open-Duo (inner display) shot:** 1 Standings **upright** (2007×2853) · 2 Entry
  sheet **sideways** (2853×2007) · 3 Final standings **upright** · 4 Setup **sideways**. The user's
  choice; it differs from the Designer's earlier picks (sideways / upright / upright / sideways). The
  mockup's Upright/Sideways switches now default to the approved orientation; the set still shows
  Apple's "across orientations" note with two of each.
- **Sideways iPhone previews (iPhone 17 Pro Max, 956×440pt) accepted as they stand.** With five
  players the standings, setup list and final table show about four rows and scroll; the user looked
  and asked for no change. The smaller-row-height idea is passed to the Engineer and Tester as an
  informational note only, not a requirement.
- Designer stage complete; spec written to `design-refinement.md`.
