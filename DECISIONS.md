# Decisions

Project-level decisions that should be permanently recorded.
Maintained by The Chronicler.

---

## App Refinement — 2026-06-06

A batch of refinements from a comprehensive app review (see `pipeline/app-refinement/findings.md`).

**Decision:** Removed the "No one"/"Nobody" round-ender chip; a specific player must always be selected.
**Rationale:** In Skyjo a round always ends when a player turns over their last card, so "nobody ended it" is not a real state. The chip's "Skip" label also misled users into silently disabling the doubling rule.
**Implications:** `ScoreEntrySheet` gates Confirm on `skyjoPlayerID != nil`. Refines the prior "Skyjo question must be answered" decision.

---

**Decision:** The doubling rule lives in one shared function, `GameSession.isDoubled(raw:minOther:)`.
**Rationale:** It was implemented twice (engine + entry-sheet preview) and had to be hand-kept in sync. A single source of truth, unit-tested, prevents drift.
**Implications:** Views must call `GameSession.isDoubled` rather than reimplement the rule. The live preview and the committed result are guaranteed to agree.

---

**Decision:** Score-status thresholds are named constants — `GameSession.bustThreshold` (100) and `dangerThreshold` (85) — surfaced via `GameSession.scoreStatus(for:)`.
**Rationale:** The 100 game-over value was hardcoded in several views; an "approaching" cue needed a second threshold. Centralizing both removes magic numbers and drives the amber/red scoreboard cues.
**Implications:** Use these constants and `scoreStatus(for:)`; do not hardcode 85/100.

---

**Decision:** `GameSessionSnapshot` carries an optional `schemaVersion` (current 1).
**Rationale:** The save file had no version tag, so any future model change would make old files fail to decode and silently wipe an in-progress game. An optional field is backward-compatible — legacy files decode as `nil`.
**Implications:** When the persisted model changes, bump `currentVersion` and branch on it to migrate. Never make `schemaVersion` non-optional.

---

## Numpad Negative Toggle — 2026-06-02

**Decision:** Score entry uses a custom calculator-style numpad embedded in the
sheet, with a `+/−` sign toggle in the lower-left. This **reverses** the prior
decision that "the negative score toggle lives in the keyboard toolbar, not the
input row."

**Rationale:** The toolbar button was not discoverable — users who hadn't seen
it assumed negative scores couldn't be entered. A persistent numpad matching the
iOS Calculator layout aligns with a mental model users already have, and puts the
sign toggle exactly where they expect it.

**Implications:** The system `.numberPad` keyboard and its keyboard toolbar are no
longer used on the score entry sheet. Player rows are tap-to-focus targets with a
brand-colored focus ring; the numpad drives all digit, sign, and delete input for
the focused player. Digit input is bounded (max 3 characters per score). The
`isNegative` state is still owned by `ScoreEntrySheet` as `[UUID: Bool]`, but is
now driven by the numpad toggle rather than a toolbar button binding.

---

## Session Persistence — 2026-05-24

**Decision:** Use a separate `GameSessionSnapshot` Codable value type instead of making `GameSession` directly Codable.

**Rationale:** `GameSession` is an `ObservableObject` class with `@Published` properties. The `@Published` property wrapper interferes with synthesized `Codable` conformance — the compiler generates init parameters for the backing storage (`_rounds`) that don't match the JSON keys. A lightweight value type with the same fields encodes and decodes cleanly with no customization.

**Implications:** Any new persistent state must be added to `GameSessionSnapshot`, not to `GameSession` directly. The snapshot is the serialization boundary.

---

**Decision:** Save to `FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)` as `active-game.json`, written with `.atomic` flag.

**Rationale:** Application Support is the correct location for app-generated files that should not be exposed to the user. Atomic writes prevent corrupt files from being written if the app is killed mid-save — the old file remains intact until the new one is fully written and swapped in.

**Implications:** The directory may not exist on first write; `createDirectory(withIntermediateDirectories: true)` is called before writing.

---

**Decision:** All `SessionStore` operations (`save`, `load`, `clear`) fail silently — no exceptions propagate, no alerts shown.

**Rationale:** Persistence is a convenience, not a critical path. If the file system is unavailable or a write fails, the app still functions normally — the user just won't get restore behavior on the next launch. Surfacing a disk-error alert during a card game would be a poor experience for an unlikely edge case.

**Implications:** Do not add error propagation to `SessionStore`. If debugging is needed, add a print statement locally and remove before committing.

---

**Decision:** `commitRound` calls `SessionStore.clear()` (not `save`) when `isGameOver` is true.

**Rationale:** If state were saved after a game-ending round, a user who quits from the win screen would restore to a "finished" game on next launch — a confusing state with nowhere to go. Clearing immediately when the game ends ensures the file only ever represents an in-progress game.

**Implications:** The win screen and all post-game navigation always launch to the setup screen on next cold start.

---

**Decision:** `Route.game` in `SkyjoScorekeeperApp` carries a `GameSession` value (not `[Player]`), so a restored session can be injected directly.

**Rationale:** The original `Route.game(players: [Player])` created a `GameSession` inside the view. Injecting a pre-built session is the only way to pass a restored session (built from a snapshot) into `ScoringView` — constructing `GameSession(players:)` inside the route would clear the saved state before restore could happen.

**Implications:** `ScoringView.init` takes `session: GameSession` directly. `SkyjoScorekeeperApp` is the single construction point for all `GameSession` instances.

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
