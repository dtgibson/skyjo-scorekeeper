# Design Spec — iPad Layout

**Feature:** ipad-layout
**Session:** 001
**Date:** 2026-05-15
**Stage:** 4 — The Designer
**Source:** prd.md (approved)

---

## Design Direction

All four screens use a single layout pattern: content is constrained to 600pt max width and centered horizontally. On iPad, equal whitespace flanks the content column on both sides. On iPhone, the constraint has no effect — layout is identical to today.

The constraint boundary is invisible to users. No decorative borders, card outlines, or background fills are added to mark the content edge. The centering is achieved purely through SwiftUI's `frame(maxWidth:)` + `.center` alignment.

---

## Shared Layout Pattern

Every screen wraps its primary content in:

```swift
.frame(maxWidth: Theme.contentMaxWidth)
.frame(maxWidth: .infinity)
```

The inner frame caps the width. The outer frame expands to fill available space and centers the inner frame. This two-frame idiom is the standard SwiftUI approach for centered max-width layouts.

---

## Screen-by-Screen Spec

### GameSetupView

**Content region:** Player name rows, "Add Player" button, "Start Game" button.

- Wrap the VStack containing the player list, add-player button, and start button in the two-frame idiom.
- Horizontal padding inside the content region: unchanged from current iPhone values.

---

### ScoringView

**Content region:** Nav bar (End Game / Round N / Undo), standings card, "Enter Round N Scores" button.

Three elements, all constrained to `contentMaxWidth`:

- **Nav bar:** The HStack containing the three nav controls is wrapped in the two-frame idiom. Controls stay at their relative positions within the constrained width — End Game left-aligned, Round label centered, Undo right-aligned.
- **Standings card:** The card VStack is wrapped in the two-frame idiom.
- **Primary button:** The "Enter Round N Scores" button is wrapped in the two-frame idiom.

---

### ScoreEntrySheet

**Content region:** Scroll content (player score rows, Skyjo question section), Confirm button.

- The scroll view's content VStack is wrapped in the two-frame idiom.
- The Confirm button, positioned outside the scroll view, is also wrapped in the two-frame idiom.
- Sheet presentation style is unchanged — this is a `.sheet`, not a full-screen cover.

---

### WinView

**Content region:** Winner hero section, final standings list, action buttons ("New Game — Same Players", "Start Fresh").

- The VStack containing all win-screen content is wrapped in the two-frame idiom.
- Both action buttons are included within the same constrained region.

---

## Theme Constant

```swift
// Theme.swift
static let contentMaxWidth: CGFloat = 600
```

This is the single source of truth. All four views reference `Theme.contentMaxWidth` — no view hardcodes a width value.

---

## Visual Reference

Mockup: `pipeline/ipad-layout/design.html`

The mockup shows all four screens in an 834pt-wide iPad frame with the 600pt content boundary marked with dashed lines. Approved 2026-05-15.

---

## What Is Not Changing

- Colors, typography, spacing, corner radii — all unchanged
- Navigation structure — unchanged
- No new views, sheets, or modal presentations
- No changes to models, game logic, or data layer
- iPhone layout — pixel-identical to pre-feature behavior
