# Strategic Brief — Accessibility

## What We're Building
Comprehensive accessibility support across all four app screens, following Apple's accessibility best practices — VoiceOver, Dynamic Type, Reduce Motion, and high contrast compatibility — so that any player at the table can use the app regardless of ability.

## Why Now
The app is live and the core experience is working well. Accessibility is the highest-integrity improvement available: it costs nothing in new infrastructure, doesn't touch game logic, and makes the app genuinely available to players who currently can't use it. App Store reviewers also weigh accessibility — this strengthens the submission going forward.

## The User Problem
A player with a visual impairment, motor disability, or large text preference opens the app and finds it either unnavigable by VoiceOver or visually broken at their preferred text size. The scores are presented as color-coded circles with no screen-reader context. Score entry requires reading and tapping elements that have no accessibility labels. The app signals "we didn't think about you."

## Success Criteria
- A VoiceOver user can complete a full game — setup, scoring, win — without sighted assistance
- The app is navigable by Voice Control using spoken element names
- All text scales gracefully to the largest Dynamic Type sizes without truncation or overlap
- Animations respect the system Reduce Motion setting
- No information is conveyed by color alone
- The app passes Xcode's Accessibility Inspector with no critical issues

## Scope
- **VoiceOver labels and hints** on all interactive elements across all four screens — player avatars, score rows, buttons, text fields, Skyjo chips, nav bar controls
- **VoiceOver groupings** for composite elements — standing rows, score input rows, final rank rows — so they read as coherent units rather than disconnected fragments
- **Accessibility values** for live data — current round number, player totals, leader status — so VoiceOver announces meaningful context
- **Dynamic Type** — replace all hardcoded font sizes with scaled equivalents using `Font.system(.body)` etc., preserving the SF Rounded design
- **Reduce Motion** — replace or disable animations when `accessibilityReduceMotion` is true
- **Non-color alternatives** — the leader indicator (green dot) and winner row highlight currently rely on color alone; add text/trait equivalents for VoiceOver
- **High contrast compatibility** — verify all text and interactive elements meet WCAG AA contrast ratios
- **Large Content Viewer** — support for avatar initials and small interactive elements at large text sizes

## Out of Scope
- RTL (right-to-left) layout
- Custom Switch Control navigation patterns beyond what SwiftUI provides automatically
- Braille display optimization
- watchOS or other platform accessibility
- Any change to game logic, models, or navigation

## Key Decisions
- Dynamic Type will use semantic text styles (`Font.system(.body, design: .rounded)` etc.) rather than hardcoded point sizes — the design stays SF Rounded throughout
- Animations will use `@Environment(\.accessibilityReduceMotion)` to conditionally disable, not replace, transitions
- VoiceOver grouping will use `.accessibilityElement(children: .combine)` where it improves the narration experience, and `.ignore` where child elements would be redundant
- Color-only indicators will get supplemental `.accessibilityLabel` context rather than visual redesigns — iPhone layout stays unchanged
