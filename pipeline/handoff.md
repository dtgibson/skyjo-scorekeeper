# Pipeline Handoff — iPad Layout Complete

## What was built

iPad Layout adapts all four app screens so the app looks and feels native on iPad rather than a stretched iPhone layout. Content on each screen is now centered within a 600pt column — on iPad, equal whitespace flanks the content on both sides; on iPhone, nothing changes.

The complete set of screens adapted:
1. **Game Setup** — player list, Add Player button, and Start Game button are centered and width-constrained
2. **Scoring View** — nav bar (End Game / Round N / Undo), standings card, and Enter Scores button are all constrained
3. **Score Entry Sheet** — player score rows, Skyjo question section, and Confirm button are constrained within the sheet
4. **Win Screen** — winner hero section, final standings card, and action buttons are centered and constrained

A single constant — `Theme.contentMaxWidth = 600` — governs all four screens. Changing it in one place changes every screen.

Also fixed during QA: the winner row background on the Win screen was too subtle to distinguish (opacity 0.06 → 0.18).

## All artifacts produced

**Session 1 artifacts:**
- `pipeline/ipad-layout/strategic-brief.md`
- `pipeline/ipad-layout/prd.md`
- `pipeline/ipad-layout/schema.md`
- `pipeline/ipad-layout/design-spec.md`
- `pipeline/ipad-layout/design.html`

**Session 2 code (modified files):**
- `SkyjoScorekeeper/Theme.swift` — `contentMaxWidth: CGFloat = 600` added
- `SkyjoScorekeeper/Views/GameSetupView.swift` — two-frame idiom applied
- `SkyjoScorekeeper/Views/ScoringView.swift` — two-frame idiom applied
- `SkyjoScorekeeper/Views/ScoreEntrySheet.swift` — two-frame idiom applied
- `SkyjoScorekeeper/Views/WinView.swift` — two-frame idiom applied; winner row opacity bumped

**Documentation updated:**
- `PRODUCT_CONTEXT.md` — iPad Layout feature and new decisions recorded
- `CLAUDE.md` — two-frame idiom convention added
- `ROADMAP.md` — iPad Layout moved to Shipped, Accessibility is now Up Next item 1

## Status

iPad Layout is complete. The app now supports iPad natively. To ship to users, archive a new build in Xcode and submit to App Store Connect — iPad screenshots (12.9-inch) are required for this submission.

## What comes next

The next roadmap item is **Accessibility** — VoiceOver labels, Dynamic Type support, and color contrast improvements. Run `/new-feature` to begin.
