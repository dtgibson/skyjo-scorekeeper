# PRD — Localization
**Feature:** localization
**Session:** 001
**Date:** 2026-05-16
**Stage:** 2 — The Planner
**Source:** strategic-brief.md (approved)

---

## Feature Overview

Full internationalization of Score for Skyjo into all 35 App Store languages. The app detects the device's system language and displays every visible string and VoiceOver accessibility label in that language, with no user configuration required.

---

## User Stories

**US-01** — As a French speaker, I want the app to display in French when my device is set to French, so that I don't have to read English to keep score.

**US-02** — As an Arabic speaker, I want the app layout to mirror correctly right-to-left, so that the interface feels native to my language.

**US-03** — As a VoiceOver user who speaks German, I want all spoken labels and hints to be in German, so that I can use the app without the accessibility experience breaking language.

**US-04** — As a Polish speaker, I want the round count ("3 rundy rozegrane") to follow Polish plural rules, so that the grammar isn't broken.

**US-05** — As any non-English user, I want player name placeholders ("Gracz 1", "Spieler 1") to be in my language, so the app feels built for me from the first screen.

---

## Functional Requirements

### String Coverage

**FR-01** — The app shall localize all 43 user-facing string tokens identified in the inventory below into all 35 supported languages.

**FR-02** — The following shall remain unchanged in all languages: "Skyjo" (proper noun), "−" (minus glyph in score field), score numerals.

**FR-03** — The Easter egg string ("Happy Mother's Day,\nShawn!") shall not be localized and shall always display in English.

**FR-04** — Player names entered by the user shall never be translated or altered.

### String Inventory (complete)

*Visible UI:*
- "Skyjo Scorekeeper" — "Skyjo" fixed, "Scorekeeper" translates
- "Who's playing today?"
- "PLAYERS"
- "Player %lld" (format, e.g. "Player 1")
- "Add Player"
- "Start Game"
- "Close" (Easter egg button — button label translates; surrounding text does not per FR-03)
- "STANDINGS"
- "Round %lld" (format)
- "End Game" (nav button)
- "Undo"
- "End Game?" (alert title)
- "Your current scores will be lost." (alert message)
- "Cancel"
- "Enter Round %lld Scores" (format)
- "ROUND %lld SCORES" (format)
- "WHO ENDED THE ROUND?"
- "Skip"
- "Next" (keyboard toolbar)
- "Done" (keyboard toolbar)
- "Confirm Round %lld" (format)
- "FINAL STANDINGS"
- "%lld rounds played" (plural — see FR-06)
- "%@ Wins!" (format)
- "%@ Tie!" (format, name list pre-joined by caller)
- "Game Over"
- "New Game — Same Players"
- "Start Fresh"

*Accessibility only (VoiceOver):*
- "Negative score" (toolbar button label)
- "on" / "off" (accessibility value for negative toggle)
- "Score for %@" (format)
- "Remove %@" (format)
- "%@ name" (text field label, format)
- "%@ name, required" (text field label with error, format)
- "Removes the most recent round's scores" (Undo hint)
- "Nobody called Skyjo"
- "%@ called Skyjo" (format)
- "Score doubles to %@" (format)
- ", currently leading" (standings row suffix, appended to row label)
- "First place" / "Second place" / "Third place" / "Place %lld" (format)
- ", winner" (accessibility suffix, appended to rank row label)
- "%1$@: %2$@, %3$lld points" (combined rank row label — placement, name, score)

**FR-05** — All strings shall be stored in a single `Localizable.xcstrings` String Catalog file at `SkyjoScorekeeper/Localizable.xcstrings`. No `.strings` or `.stringsdict` sidecar files shall be used.

**FR-06** — The string "%lld rounds played" shall use CLDR plural rules per locale. English requires `one` ("1 round played") and `other` ("%lld rounds played"). Each language shall receive correct plural forms for all required CLDR categories (zero, one, two, few, many, other as applicable).

**FR-07** — SwiftUI `Text` view literals (which are already `LocalizedStringKey`) shall be left as-is in code; the String Catalog entry provides the translation. Computed strings built in Swift code shall use `String(localized:)` with the appropriate format specifiers.

**FR-08** — The 35 supported locales shall be: `ar`, `ca`, `cs`, `da`, `de`, `el`, `en` (base), `es`, `es-419`, `fi`, `fr`, `fr-CA`, `he`, `hi`, `hr`, `hu`, `id`, `it`, `ja`, `ko`, `ms`, `nb`, `nl`, `pl`, `pt-BR`, `pt-PT`, `ro`, `ru`, `sk`, `sv`, `th`, `tr`, `uk`, `vi`, `zh-Hans`, `zh-Hant`.

### RTL Layout

**FR-09** — The app shall render correctly in RTL layout for Arabic (`ar`) and Hebrew (`he`). No explicit layout overrides are expected since the app already uses SwiftUI leading/trailing alignment, but RTL must be validated.

**FR-10** — The minus glyph (`−`) that appears next to a negative score shall appear on the leading side of the number in RTL locales (i.e. it shall visually precede the digit in reading direction).

### Translation Source

**FR-11** — Translations shall be produced using DeepL. Each string shall include a translator comment in the String Catalog describing its context (which screen, what the string does).

**FR-12** — The translation comment for "Skyjo Scorekeeper" shall instruct translators to leave "Skyjo" unchanged and translate only "Scorekeeper".

---

## Non-Functional Requirements

**NFR-01 — Compatibility:** The `.xcstrings` format requires Xcode 15+. The project already uses Xcode 26.5 locally. No minimum version change required.

**NFR-02 — App Size:** All 35 locales compile into the app binary. String resources are not subject to App Thinning — users can switch device languages without redownloading the app. With 43 short strings across 35 locales, the total size impact is negligible (well under 100 KB of compiled string data).

**NFR-03 — Accessibility:** All VoiceOver labels, hints, and values in the inventory shall be localized to the same 35 locales as the visible UI strings.

**NFR-04 — No Runtime Dependencies:** All translations ship with the app binary. No network call, CDN, or remote config is involved.

---

## Out of Scope

- App Store Connect listing translations (title, description, keywords, screenshots)
- Locale-specific number formatting for scores (plain integers; standard system formatting is sufficient)
- Date or time formatting (none in the app)
- RTL validation beyond Arabic and Hebrew
- Complex script layout issues (Thai word-breaking, etc.) beyond basic rendering

---

## Open Questions

None — all decisions are resolved in this document.

---

## Success Metrics

| ID | What's Being Verified | Pass Condition |
|---|---|---|
| QA-01 | French UI strings | Device set to French: all visible strings in French; "Skyjo" unchanged |
| QA-02 | German UI strings | Device set to German: all visible strings in German; "Skyjo" unchanged |
| QA-03 | Arabic RTL layout | Device set to Arabic: layout mirrors, text RTL, no clipped or overlapping elements |
| QA-04 | Hebrew RTL layout | Device set to Hebrew: layout mirrors correctly |
| QA-05 | Japanese rendering | Device set to Japanese: all strings render without truncation or layout breakage |
| QA-06 | English plural | 1 round: "1 round played"; 2+ rounds: "N rounds played" |
| QA-07 | Russian plural | 1 round: correct; 2 rounds: correct; 5 rounds: correct per CLDR Russian rules |
| QA-08 | VoiceOver in French | Device set to French with VoiceOver on: accessibility labels read in French |
| QA-09 | Easter egg unchanged | Any non-English locale: Easter egg reads "Happy Mother's Day, Shawn!" |
| QA-10 | Player names untouched | Any locale: user-entered player names display exactly as typed |
| QA-11 | Negative score RTL | Arabic locale: minus glyph appears on leading (right) side of score digit |
| QA-12 | All 35 locales present | `Localizable.xcstrings` contains 35 locale entries; build succeeds |
| QA-13 | Existing tests pass | All existing unit tests pass after localization changes |
