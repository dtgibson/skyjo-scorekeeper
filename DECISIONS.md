# Decisions

Project-level decisions that should be permanently recorded.
Maintained by The Chronicler.

---

## Localization — 2026-05-24

**Decision:** Use a single `Localizable.xcstrings` String Catalog (Xcode 15+ format) as the sole source of localized strings. No `.strings` or `.stringsdict` sidecar files.

**Rationale:** xcstrings consolidates all locales into one JSON file, supports CLDR plural rules natively, and integrates with Xcode's string extraction tooling. The project already uses Xcode 26.5 locally and macos-15 in CI, both of which fully support the format.

**Implications:** Any future feature that adds user-facing strings or accessibility labels must add entries to this file. The catalog must be added to the Xcode project target when first created (drag into Xcode).

---

**Decision:** Translations sourced via DeepL. Each string includes a translator comment describing its screen and context.

**Rationale:** DeepL produces higher-quality output than machine translation for short UI strings, particularly for inflected languages (German, Russian, Polish). Comments give translators enough context to disambiguate ambiguous strings.

**Implications:** When adding new strings in future features, include a `comment` field in the xcstrings entry describing where the string appears and what it does.

---

**Decision:** The Easter egg string ("Happy Mother's Day,\nShawn!") is permanently excluded from localization and always displays in English.

**Rationale:** It is a personal message, not a user-facing UI string. Translating it would be meaningless and potentially confusing.

**Implications:** This string must never be added to the catalog. It stays hardcoded in `EasterEggOverlay.swift`.

---

**Decision:** 35 non-English locales supported, matching the full App Store language list at time of shipping.

**Rationale:** Supporting all App Store languages at launch avoids a piecemeal rollout and ensures no user sees an English-only experience. String data is static and ships with the binary — no ongoing cost per locale.

**Implications:** New locales can be added to the catalog without a code change. If Apple adds new supported languages in the future, they can be added by appending a locale block to the xcstrings file.
