# Design Spec — Accessibility

**Feature:** accessibility
**Session:** 001
**Stage:** 4 — The Designer
**Source:** prd.md (approved), design.html (approved)

---

## Design Philosophy

The accessibility pass is intentionally invisible at default settings. A user with no accessibility needs open the app and sees the same app they always have — with one exception: the crown symbol ♛ next to the leading player. Every other change is a behind-the-scenes label, trait, or color variant that activates only when an assistive technology or accessibility setting is engaged.

---

## Visual Changes at Default Settings

### Leader Indicator — ScoringView
**Change:** Add `crown.fill` SF Symbol alongside the existing green dot in `StandingRowView`.

- Crown renders in the same green as the dot
- Size: `.caption` weight, aligned vertically with the dot
- Both crown and dot show for all users — the crown reinforces leader status for color-blind users, while the dot remains for users who perceive color
- No other visual element changes at default text size

---

## VoiceOver Annotations

### GameSetupView
| Element | Accessibility Treatment |
|---|---|
| Player name text field | `.accessibilityLabel("Player \(position) name")` |
| Player avatar circle | `.accessibilityHidden(true)` — decorative |
| Remove player button | `.accessibilityLabel("Remove \(player.name)")` |
| "PLAYERS" heading | `.accessibilityAddTraits(.isHeader)` |
| Validation error state | Announce error without relying on red color — add `.accessibilityLabel` that includes "required" or error text |

### ScoringView
| Element | Accessibility Treatment |
|---|---|
| Standing row (combined) | `.accessibilityElement(children: .combine)` → label: `"\(name), \(total) points\(isLeader ? ", currently leading" : "")"` |
| Leader dot | Folded into combined row label — not a separate VoiceOver stop |
| Crown symbol | Folded into combined row label — not a separate VoiceOver stop |
| "STANDINGS" heading | `.accessibilityAddTraits(.isHeader)` |
| Undo button | `.accessibilityHint("Removes the most recent round's scores")` + `.accessibilityElement` disabled trait when no rounds played |

### ScoreEntrySheet
| Element | Accessibility Treatment |
|---|---|
| Drag handle | `.accessibilityHidden(true)` — decorative |
| "ROUND N SCORES" heading | `.accessibilityAddTraits(.isHeader)` |
| Score input row | `.accessibilityElement(children: .combine)` — label includes player name; score field has `.accessibilityLabel("Score for \(name)")` |
| Negative toggle | `.accessibilityLabel("Negative score")` + `.accessibilityValue(isNegative ? "on" : "off")` |
| Doubling preview (×2 → 16) | Included in combined row narration when visible |
| "WHO ENDED THE ROUND?" heading | `.accessibilityAddTraits(.isHeader)` |
| Skyjo chip — player | `.accessibilityLabel("\(name) called Skyjo")` + selected state |
| Skyjo chip — Skip | `.accessibilityLabel("Nobody called Skyjo")` + selected state |
| Confirm button | Disabled trait conveyed via `.accessibilityElement` when not all scores entered |

### WinView
| Element | Accessibility Treatment |
|---|---|
| Trophy / handshake emoji | `.accessibilityLabel("Winner")` or `.accessibilityLabel("It's a tie")` — or `.accessibilityHidden(true)` if headline immediately below duplicates it |
| Final ranking row (combined) | `.accessibilityElement(children: .combine)` → label: `"\(placement): \(name), \(total) points\(isWinner ? ", winner" : "")"` |
| Medal emoji | Folded into combined row label — not a separate VoiceOver stop |
| "FINAL STANDINGS" heading | `.accessibilityAddTraits(.isHeader)` |

---

## Dynamic Type

All text in the app must use semantic text styles rather than hardcoded point sizes. The SF Rounded typeface is preserved by passing `design: .rounded` to every `Font.system(...)` call.

### Style Mapping
| Current usage (approx.) | Semantic style |
|---|---|
| Large display numbers (hero score) | `.largeTitle` |
| Section headings (STANDINGS, etc.) | `.headline` |
| Primary body text, names, scores | `.body` |
| Secondary labels, subtitles | `.subheadline` or `.callout` |
| Caption labels, small hints | `.caption` or `.caption2` |

### Row Height Behavior
- Row heights that are currently fixed (`frame(height: N)`) must use `frame(minHeight: N)` so they expand at large text sizes rather than clipping
- Padding values remain constant — only minimum heights flex

---

## Reduce Motion

All animations are conditionally disabled when `@Environment(\.accessibilityReduceMotion)` is `true`.

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Pattern:
withAnimation(reduceMotion ? nil : .easeInOut) { ... }

// Or for view-level transitions:
.animation(reduceMotion ? nil : .spring(), value: someState)
```

No replacement animation is needed — state changes occur immediately.

---

## Increase Contrast

When `@Environment(\.colorSchemeContrast) == .increased`, substitute high-contrast color variants for all custom colors.

### Standard vs. High Contrast Color Variants

All contrast ratios are measured against white text (#FFFFFF).

| Color | Standard | Standard Ratio | High Contrast | HC Ratio |
|---|---|---|---|---|
| Brand (indigo) | `#3730A3` | ~6.9:1 ✓ | `#2a2475` | ~9:1 ✓ |
| Blue | `#0072B2` | ~5.5:1 ✓ | `#005a8e` | ~7:1 ✓ |
| Vermillion | `#D55E00` | ~4.6:1 ✓ | `#b04b00` | ~6:1 ✓ |
| Green | `#009E73` | ~3.3:1 ✗ | `#007a59` | ~4.7:1 ✓ |
| Sky blue | `#56B4E9` | ~2.5:1 ✗ | `#2a7fb5` | ~4.6:1 ✓ |
| Orange | `#E69F00` | ~2.4:1 ✗ | `#a07200` | ~5.0:1 ✓ |
| Pink-purple | `#CC79A7` | ~2.6:1 ✗ | `#a0537e` | ~4.7:1 ✓ |
| Yellow | `#F0E442` | ~1.3:1 ✗ | `#7a7000` | ~5.2:1 ✓ (switch to dark text) |

> Note: Yellow at standard contrast cannot meet 4.5:1 with white text. The high-contrast variant switches to a dark olive that meets 4.5:1 with white, but the Engineer should verify whether switching the avatar text color to dark for this palette index is correct in context. An alternative is to swap to a visually adjacent color that is both color-blind safe and AA-compliant with white.

### Implementation Pattern
```swift
@Environment(\.colorSchemeContrast) var colorContrast

var playerColor: Color {
    if colorContrast == .increased {
        return Theme.playerColorHighContrast(at: index)
    }
    return Theme.playerColor(at: index)
}
```

High-contrast variants are added to `Theme.swift` as a parallel lookup — `playerColorHighContrast(at:)` and `playerTextColorHighContrast(at:)`.

---

## Non-Color Leader Indicator

**Element:** `StandingRowView` in `ScoringView`

**Implementation:**
```swift
HStack(spacing: 4) {
    Circle()
        .fill(Color(hex: "#009E73"))
        .frame(width: 8, height: 8)
    Image(systemName: "crown.fill")
        .font(.caption2)
        .foregroundStyle(Color(hex: "#009E73"))
}
```

The crown and dot share the same green color. Both appear for all users — the crown is not VoiceOver-only. The combined VoiceOver label still announces "currently leading" regardless of visual state.

---

## Artifacts

- `pipeline/accessibility/design.html` — interactive mockup with VoiceOver Labels, Increase Contrast, and Large Text toggles
- `pipeline/accessibility/design-spec.md` — this document
