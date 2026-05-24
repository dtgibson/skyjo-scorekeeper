# Design Spec — Localization

**Feature:** localization
**Session:** 001
**Stage:** 4 — The Designer
**Source:** prd.md (approved), design.html (approved)

---

## Visual Direction

Localization introduces no new visual design. The app's established brand — indigo #3730A3, SF Rounded typography, native iOS components — is preserved in every locale. The only observable difference between an English user and a French user is the language of the text itself.

---

## String Extraction Strategy

### SwiftUI Text literals — no code change required

Every `Text("literal string")` in the app already accepts `LocalizedStringKey`. When a matching entry exists in `Localizable.xcstrings`, SwiftUI resolves it automatically at runtime. The Engineer does not touch these call sites.

Affected views (complete list):
- `GameSetupView.swift` — all section headers and button labels
- `ScoringView.swift` — section headers, nav bar items
- `ScoreEntrySheet.swift` — section headers, keyboard toolbar buttons
- `WinView.swift` — section headers, action buttons

### Computed Swift strings — require `String(localized:)` wrapping

Any string built with string interpolation or passed as a `String` (not `Text`) must be converted. The Engineer will wrap these with `String(localized:)` using the appropriate format specifiers.

Computed strings requiring wrapping (from FR inventory):
- `"Player \(n)"` → `String(localized: "Player \(n, specifier: "%lld")")` using the `"Player %lld"` catalog key
- `"Round \(n)"` → `String(localized:)` using `"Round %lld"`
- `"Enter Round \(n) Scores"` → `String(localized:)` using `"Enter Round %lld Scores"`
- `"ROUND \(n) SCORES"` → `String(localized:)` using `"ROUND %lld SCORES"`
- `"Confirm Round \(n)"` → `String(localized:)` using `"Confirm Round %lld"`
- `"%lld rounds played"` → `String(localized:)` using plural-aware key
- `"\(name) Wins!"` → `String(localized:)` using `"%@ Wins!"`
- `"\(name) Tie!"` → `String(localized:)` using `"%@ Tie!"`
- All accessibility labels built with string interpolation (see VoiceOver section below)

---

## Localizable.xcstrings Structure

**File location:** `SkyjoScorekeeper/Localizable.xcstrings`

**Format:** Apple String Catalog (Xcode 15+). Already enabled in the project via `STRING_CATALOG_GENERATE_SYMBOLS = YES`.

**Single file — no sidecar files.** No `.strings` or `.stringsdict` files will be created.

**All 35 locales ship in every install.** String Catalogs compile all locales into the app binary. There is no language-based App Thinning for string resources in App Store apps — users can switch their device language at any time and the app will immediately reflect the new locale, with no additional download required.

### Translator comment convention

Every string in the catalog includes a `"comment"` field describing:
1. Which screen it appears on
2. What the string does in context
3. Any constraint on translation (e.g., "Leave 'Skyjo' unchanged")

### Plural string

Only one string requires CLDR plural rules: `"%lld rounds played"`. All other strings use simple stringUnit entries.

Example catalog structure for the plural string:
```json
"%lld rounds played" : {
  "comment" : "Subtitle on the win screen. Shows total completed rounds. One form: '1 round played'. Other form: 'N rounds played'.",
  "localizations" : {
    "en" : { "variations" : { "plural" : {
      "one"   : { "stringUnit" : { "value" : "1 round played" }},
      "other" : { "stringUnit" : { "value" : "%lld rounds played" }}
    }}},
    "ru" : { "variations" : { "plural" : {
      "one"   : { "stringUnit" : { "value" : "%lld раунд сыгран" }},
      "few"   : { "stringUnit" : { "value" : "%lld раунда сыграно" }},
      "many"  : { "stringUnit" : { "value" : "%lld раундов сыграно" }},
      "other" : { "stringUnit" : { "value" : "%lld раунда сыграно" }}
    }}}
  }
}
```

### Fixed strings (never translated)

Per FR-02 and FR-03:
- `"Skyjo"` as a proper noun — translator comments on every containing string instruct "leave 'Skyjo' unchanged"
- The `−` minus glyph — remains unchanged in all locales
- Score numerals — system-formatted integers, no localization needed
- Easter egg string `"Happy Mother's Day,\nShawn!"` — excluded from catalog entirely; hardcoded in `EasterEggOverlay.swift`

---

## RTL Layout (Arabic and Hebrew)

SwiftUI's `leading`/`trailing` alignment primitives automatically mirror when the device locale is Arabic or Hebrew. No explicit `.environment(\.layoutDirection, .rightToLeft)` override is needed.

**Verified RTL elements:**
- Navigation bar: back/leading buttons appear on the right in RTL
- Player rows: avatar appears on the right, name reads right-to-left
- Score entry rows: the inline `−` glyph and `TextField` HStack mirror correctly (glyph leads the number in reading direction)
- Standings rows: crown indicator, player name, and score column all flip
- Win screen hero and standings: full RTL rendering

**Inline minus glyph (ScoreEntrySheet):**
The `−` symbol is positioned via `HStack(spacing: 1)` with `opacity(isNegative ? 1 : 0)`. In RTL, the HStack reads right-to-left, so the glyph naturally appears on the leading (right) side of the digit — satisfying FR-10 with no additional work.

---

## VoiceOver Accessibility Labels

All accessibility labels built with string interpolation must use `String(localized:)` so they resolve in the device locale.

| Current code | Localized key |
|---|---|
| `"Score for \(name)"` | `"Score for %@"` |
| `"Remove \(name)"` | `"Remove %@"` |
| `"\(name) name"` | `"%@ name"` |
| `"\(name) name, required"` | `"%@ name, required"` |
| `"\(name) called Skyjo"` | `"%@ called Skyjo"` |
| `"Score doubles to \(doubled)"` | `"Score doubles to %@"` |
| `"\(placement): \(name), \(total) points"` | `"%1$@: %2$@, %3$lld points"` |

Static accessibility labels (`"Negative score"`, `"on"`, `"off"`, `"Nobody called Skyjo"`, `"Removes the most recent round's scores"`, placement strings, `", currently leading"`, `", winner"`) are `Text`-style literals in `.accessibilityLabel("")` calls — these are `String`, not `Text`, so they must use `String(localized:)`.

---

## Translation Workflow

All 43 strings are translated via DeepL using the translator comments as context. The Engineer populates the catalog with English source strings and comments; DeepL provides translations for all 34 non-English locales. No professional review is required for a utility app with short, context-free strings.

The Engineer will translate in one batch after all source strings are in the catalog, using the `deepl` CLI or API.

---

## Screens Affected

| Screen | File | Work Required |
|---|---|---|
| Game Setup | `GameSetupView.swift` | All `Text` literals auto-resolve; `"Player %lld"` in placeholder needs `String(localized:)` |
| Player Row | `PlayerRowView.swift` | Accessibility labels for text field and remove button need `String(localized:)` |
| Scoring | `ScoringView.swift` | `"Round %lld"` in nav title; accessibility label for standing rows |
| Score Entry | `ScoreEntrySheet.swift` | `"ROUND %lld SCORES"`, `"Confirm Round %lld"`, `"Enter Round %lld Scores"`, all per-player accessibility labels |
| Win Screen | `WinView.swift` | `"%lld rounds played"` (plural), `"%@ Wins!"`, `"%@ Tie!"`, rank row accessibility labels |
| Easter Egg | `EasterEggOverlay.swift` | No changes — hardcoded English string excluded from catalog |

---

## No New Views or Components

Localization requires no new SwiftUI views. Every visible change is a string substitution that happens at runtime via the String Catalog. The Engineer's work is:

1. Create `Localizable.xcstrings` with all 43 source strings and translator comments
2. Wrap computed strings with `String(localized:)`
3. Run DeepL translation for all 34 non-English locales
4. Validate RTL and plural behavior in the simulator

---

## Artifacts

- `pipeline/localization/design.html` — interactive mockup showing 6 locales × 3 screens
- `pipeline/localization/design-spec.md` — this document
