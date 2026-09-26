# Handoff — iOS 27 Platform Readiness (Paused)

## What We Accomplished

We scoped and designed a readiness pass so Skyjo Scorekeeper ships on Xcode 27 /
iOS 27 and works well on iPhone Duo, iPhone Mirroring, and iPad in both
orientations. The Evaluator confirmed the requirements (iOS 27 SDK required from
April 2027; iPhone Duo is real and ships Oct 23 with iOS 27.1; iOS 27 makes iPhone
apps resizable). The Designer's refinement was approved after three rounds with you:
system toolbar and grabber, and the entry sheet, win screen, and setup reflowing by
available space. Horizontal iPad and Duo share the side-by-side entry sheet, and the
layouts hold up with 2 to 8 players. The app icon stays as it is for now.

## What Has Been Saved

- `pipeline/project.json` (created this session)
- `pipeline/ios-27-platform-readiness/change-brief.md`
- `pipeline/ios-27-platform-readiness/platform-research.md`
- `pipeline/ios-27-platform-readiness/design-refinement.md`
- `pipeline/ios-27-platform-readiness/design.html`

## Where We Are

Stage 2 of 7 (The Designer) is complete and approved. Paused at the handoff to
The Engineer (Stage 3). No code has been written yet.

## Resume Prompt

To resume this session: run `/weft` in a Claude Code session in
this project. It reads saved state and picks up exactly here. (The
prompt below is an explicit fallback if you want to paste it.)

---

Resume the Weft Improve build `ios-27-platform-readiness` for project
skyjo-scorekeeper (design-pass shape, 7 steps). Last completed stage: 2 (The
Designer, approved). Next: Stage 3, The Engineer, building
`design-refinement.md` + `design.html` against `change-brief.md`. Execution mode:
Studio Style (user participates only in the Designer), so Engineer, Tester, and
Auditor run hands-off and the deploy sign-off is gated. Load
`pipeline/session-state.json` first.
