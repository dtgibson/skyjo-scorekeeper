# Designer status — complete (2026-10-29)

The Designer stage (step 2 of 7) is finished. The user answered the two open questions on
2026-10-29 and the design is approved as round eight. The spec The Engineer builds from is
`pipeline/iphone-duo-store-listing/design-refinement.md`; the mockup is
`pipeline/iphone-duo-store-listing/design.html` (assets in `mockup-assets/`), with each open-Duo
shot's Upright/Sideways switch defaulting to the approved orientation.

## Approved
- Duo inner display, per shot: 1 Standings upright · 2 Entry sheet sideways · 3 Final standings
  upright · 4 Setup sideways (user's choice; recorded in `decisions.md`).
- Sideways-iPhone previews accepted as they stand; the "about four rows visible with five players"
  observation goes to the Engineer and Tester as information only.
- Everything in *Locked by the user* below.

## Locked by the user (do not reopen)
- Apple's Duo / iPhone / iPad bezels as-is; no drawn crease.
- May 2026 family names and finishing order: Shawn wins on 80, Phoebe 90, Elena 96,
  Mike 100, David 119. Round 1: David 7 doubled to 14. Round 2 standings: Shawn 5,
  Elena 8, Phoebe 10, Mike 12, David 14.
- Existing subtitle, description and keywords unchanged.
- Promotional text (145/170) and header line as shown in `design.html` and quoted in
  `design-refinement.md`; header line "Keep score. See who's winning." / "On iPhone, iPad and iPhone Duo".
- Shot 3 caption: "The game ends at 100. Lowest score wins."
- What's New option 2: "Turn your iPhone sideways and the scoreboard turns with it.
  New App Store screenshots too, including iPhone Duo."
- Captions in plain shopper language: no crease/fold/development talk, no "called
  Skyjo", doubling rule = the player who ends the round without the lowest score.
- Landscape on iPhone is allowed (user decision, see decisions.md and the change-brief
  amendment).

## Showing the mockup again
If the preview link has died with a session, re-serve it:
  1. `nohup python3 pipeline/iphone-duo-store-listing/mockup-assets/serve.py 18791 pipeline/iphone-duo-store-listing >/dev/null 2>&1 &`
     (pick another free port if 18791 is taken; `serve.py` sends the UTF-8 charset header,
     plain `http.server` does not and the images grow stray "?" glyphs)
  2. `/Applications/Tailscale.app/Contents/MacOS/Tailscale serve --bg --set-path /skyjo-duo-store http://127.0.0.1:18791`
  3. Link: `https://<your-tailnet-host>/skyjo-duo-store/design.html`
  Never give a `file://` link.

## Next
The Orchestrator runs the Stage 2 gate and hands over to The Engineer with `design-refinement.md`.
