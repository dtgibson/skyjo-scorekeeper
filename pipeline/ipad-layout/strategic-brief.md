# Strategic Brief — iPad Layout

## What We're Building
Adaptive UI layouts across all four screens (setup, scoring, score entry, win) so the app looks and feels native on iPad rather than a stretched iPhone layout.

## Why Now
The app is live on the App Store and available on iPad today — it just runs in "scaled iPhone" mode, which looks unfinished on larger screens. Fixing this costs no new infrastructure and has no data model changes. It's a high-visibility quality improvement that affects any player who reaches for an iPad at the table.

## The User Problem
A player using an iPad to track scores sees narrow content floating in the middle of a large screen, or content stretched awkwardly wide. Neither feels intentional. The app signals "iPhone app that also installs on iPad" rather than a purpose-built tool.

## Success Criteria
- All four screens look intentional on iPad in both portrait and landscape
- Content is properly centered and width-constrained on large screens
- No layout elements appear stretched, misaligned, or oddly small
- The app passes Xcode's iPad simulator at 11-inch and 13-inch sizes without visual regressions on iPhone

## Scope
- `GameSetupView` — centered content with max-width constraint, generous padding on large screens
- `ScoringView` — standings card width-constrained, nav bar balanced
- `ScoreEntrySheet` — sheet content width-constrained, inputs readable at iPad scale
- `WinView` — hero section centered, final standings width-constrained

## Out of Scope
- Split View or Slide Over support (iPad multitasking)
- iPad-specific features (pointer/keyboard support, drag-and-drop)
- Multi-window support
- Layout changes that affect iPhone

## Key Decisions
- Use SwiftUI's `frame(maxWidth:)` with a shared constant (e.g. 600pt) as the content width ceiling — keeps all screens consistent without per-view negotiation
- No new views — adapt existing views in place
- iPad and iPhone share all models and navigation; only layout changes
