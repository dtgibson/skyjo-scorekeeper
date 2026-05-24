# Strategic Brief — Localization

## What We're Building
Full app localization into all languages available on the App Store, using iOS String Catalogs. Every visible string and VoiceOver accessibility label translates automatically based on the device's system language.

## Why Now
The app is functionally complete and well-reviewed on the App Store. Accessibility is done. The string count is very small (~35–40 unique strings), which makes this the lowest-cost localization effort possible. Skyjo originated in Germany and is most popular across Europe — French, German, Spanish, Italian, and Dutch speakers are natural users who currently get an English-only experience. Adding localization before any future feature growth keeps the translation surface small.

## The User Problem
A French family playing Skyjo at the dinner table opens a scorekeeper and sees "WHO ENDED THE ROUND?" The game's rules are familiar; the app's language is not. The friction is small but unnecessary — iOS already knows the user's language. The app just doesn't use it.

## Success Criteria
- A device set to French, German, Spanish, Japanese, Arabic, or any other supported language shows the app entirely in that language
- RTL languages (Arabic, Hebrew) render correctly without layout breakage
- The round count plural ("1 round played" vs "3 rounds played") is grammatically correct in all languages
- All VoiceOver accessibility labels and hints are also translated

## Scope
- All visible UI strings in all four screens + the Easter egg overlay
- All VoiceOver accessibility labels and hints
- Plural rules for the round count string
- RTL layout validation for Arabic and Hebrew
- All ~36 languages available on the App Store

## Out of Scope
- App Store listing translations (screenshots, description) — separate effort
- Game rule explanations or onboarding copy — there isn't any
- The Easter egg text ("Happy Mother's Day, Shawn!") — stays English
- Player names are user input and are never translated

## Key Decisions
- String Catalogs (`.xcstrings`) are the implementation format — already enabled in the project (`STRING_CATALOG_GENERATE_SYMBOLS = YES`)
- Machine translation (DeepL) is acceptable for a utility app with simple, context-free strings; professional review not required
- Player names are user input and are never translated
- "Skyjo" as a proper noun stays unchanged in all languages
