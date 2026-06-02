# Handoff — Numpad Negative Toggle (Complete)

## What We Accomplished

Replaced the hard-to-find keyboard-toolbar negative toggle with a custom
calculator-style numpad built into the score entry sheet. The `+/−` key sits
in the lower-left, matching the iOS Calculator layout, so entering a negative
score is now obvious. Player rows are tap-to-focus with a brand-colored ring,
and the system keyboard no longer appears. Shipped to `main`, CI passed, and
submitted to the App Store for review (build 7).

## What Has Been Saved

- `SkyjoScorekeeper/Views/ScoreEntrySheet.swift` — numpad rewrite
- `SkyjoScorekeeper/Localizable.xcstrings` — three new accessibility strings
- `SkyjoScorekeeper/SkyjoScorekeeper.xcodeproj/project.pbxproj` — build number → 7
- `pipeline/numpad-negative-toggle/` — change brief, QA report, security report
- `DECISIONS.md` — logged the reversal of the keyboard-toolbar decision
- `PRODUCT_CONTEXT.md` — updated the score-entry decision and feature description

## Where We Are

Improvement complete. All six stages done, shipped, and chronicled.

## Resume Prompt

To start the next thing: run `/weft` in a Claude Code session in this project.
It reads saved state and picks up fresh.
