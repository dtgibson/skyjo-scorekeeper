# Brand Design System — Skyjo Scorekeeper

## Visual Identity

**Primary color:** #3730A3 (dark purplish blue — referencing the -2 and -1 cards in Skyjo)
**Feeling:** Immediate clarity. No learning curve. The user understands the app without instructions.
**Typography:** Warm and approachable — SF Rounded, iOS's friendly rounded system font
**Reference:** Native iOS. Lean into platform components so the app renders liquid glass on iOS 26+ automatically.

## Design Token Values

| Token | Value | Usage |
|---|---|---|
| brand | #3730A3 | Primary actions, buttons, active states |
| brandLight | #5B50D6 | Supporting highlights, secondary accents |
| brandForeground | #FFFFFF | Text on primary color backgrounds |
| background | System adaptive | UIColor.systemBackground (light/dark auto) |
| foreground | System adaptive | UIColor.label (light/dark auto) |
| secondaryBackground | System adaptive | UIColor.secondarySystemBackground |
| separator | System adaptive | UIColor.separator |

## Typography

**Font:** SF Rounded (`.fontDesign(.rounded)` in SwiftUI)
**Heading weight:** Semibold (`.fontWeight(.semibold)`)
**Body size:** 17pt (iOS standard body)
**Caption size:** 13pt

## Applied To

`Theme.swift` — to be created in the Xcode project root during the first feature build.

## Visual Approach

Use native SwiftUI components throughout. Do not build custom UI where a system component exists.
On iOS 26+, `.glassBackgroundEffect()` renders liquid glass automatically — no extra work needed.
This keeps the app current with every iOS release without maintenance.

## Notes

The primary color is semantically connected to the game — the dark purplish blue of Skyjo's best
cards (-2 and -1). This gives the app a visual identity that feels native to the game, not generic.
The warm/rounded typography softens the number-heavy interface and makes the app feel approachable
during what is ultimately a social, around-the-table experience.
