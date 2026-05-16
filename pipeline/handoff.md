# Handoff — Accessibility Feature Complete

## What was built

Full accessibility support was added across all four screens of Score for Skyjo. The app now supports VoiceOver navigation, Dynamic Type text scaling, Reduce Motion (all animations suppressible), and Increase Contrast (a WCAG-AA-compliant high-contrast color palette). A non-color leader indicator (crown.fill SF Symbol) was added to the standings view. All fixed-height rows were updated to minHeight to prevent text clipping at large type sizes.

This was a pure-polish feature — no user-visible behavior changed at default system settings. The crown symbol is the only new visible element.

## Files produced

**Source changes (Swift):**
- `SkyjoScorekeeper/Theme.swift`
- `SkyjoScorekeeper/Views/GameSetupView.swift`
- `SkyjoScorekeeper/Views/PlayerRowView.swift`
- `SkyjoScorekeeper/Views/ScoringView.swift`
- `SkyjoScorekeeper/Views/ScoreEntrySheet.swift`
- `SkyjoScorekeeper/Views/WinView.swift`
- `SkyjoScorekeeper/Views/EasterEggOverlay.swift`

**Pipeline artifacts:**
- `pipeline/accessibility/strategic-brief.md`
- `pipeline/accessibility/prd.md`
- `pipeline/accessibility/schema.md`
- `pipeline/accessibility/design-spec.md`
- `pipeline/accessibility/design.html`

**Context updates:**
- `PRODUCT_CONTEXT.md` — accessibility feature + 3 new decisions
- `CLAUDE.md` — accessibility conventions + corrected CI documentation

## CI fix included

The accessibility commit also corrected a CI regression: the pipeline.yml had been pinned to Xcode 16.2, which broke when the project was opened and re-saved locally in Xcode 26.5 (LastUpgradeCheck bumped to 2650). The Xcode pin was removed and the test destination was changed from a fragile UDID-lookup to a named simulator (`platform=iOS Simulator,OS=latest,name=iPhone 16`). CI is green.

## This feature is complete

Both sessions are done. The accessibility feature is deployed to `main` on GitHub and CI is passing.

## App Store note

No new screenshots are required — the feature is invisible at default system settings. Archive from Xcode and upload to App Store Connect the same way as the iPad Layout release.

## Starting the next feature

Run `/new-feature` to begin the next item from the roadmap.
