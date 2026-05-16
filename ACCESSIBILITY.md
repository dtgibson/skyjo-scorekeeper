# Accessibility — Score for Skyjo

Score for Skyjo is designed to be fully usable by everyone. The app supports the accessibility features built into iOS and has been tested with Apple's assistive technologies.

---

## VoiceOver

The app is fully navigable with VoiceOver. Every interactive control has a descriptive label, and contextual hints are provided where helpful. Non-interactive decorative elements — player avatars, emoji, and visual flourishes — are hidden from the VoiceOver tree so it stays focused on content that matters.

Compound information that is visually presented as a single row (such as a player's name, score, and standing position) is read as a single, coherent sentence rather than as separate fragments. For example: *"First place: Alex, 34 points, winner."*

---

## Dynamic Type

All text in the app scales with the system font size setting. Layouts expand to accommodate larger type — no text is clipped or truncated at any supported size. Two visually prominent elements (the app title and the winner headline) use proportional scaling so they grow alongside the surrounding text rather than staying fixed.

---

## Reduce Motion

All animations in the app — transitions, micro-interactions, and state changes — respect the iOS Reduce Motion accessibility setting. When Reduce Motion is enabled, every animation is fully suppressed. No content is hidden or removed; only the motion is eliminated.

---

## Increase Contrast

The app includes a complete high-contrast color palette that is applied automatically when the iOS Increase Contrast setting is enabled. All player colors and brand colors in high-contrast mode meet the WCAG 2.1 AA standard (4.5:1 contrast ratio against white). The current leader in the standings is identified with both a color indicator and a crown symbol, so leadership is never conveyed by color alone.

---

## No Audio Content

Score for Skyjo contains no audio of any kind — no sound effects, no music, no spoken content, and no audio alerts. The app is inherently fully usable without hearing or with the device volume off.

---

## Switch Control and Keyboard Navigation

All interactive controls are reachable via Switch Control. The app does not rely on complex gestures — every action is available through standard tap targets sized at 44pt or larger.

---

## Feedback

If you encounter any accessibility barrier in Score for Skyjo, please reach out at [dave@dtgibson.com](mailto:dave@dtgibson.com). Accessibility issues are treated as bugs and addressed as a priority.
