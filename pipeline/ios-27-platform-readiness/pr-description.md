## iOS 27 Platform Readiness

### What this does
Gets Skyjo Scorekeeper ready to ship on Xcode 27 / iOS 27 and to behave well in any window shape: iPhone Duo's wide inner display, iPhone Mirroring pulled short, and resizable iPad windows. The score entry sheet, win screen and setup screen now reflow by the space they actually have (never by orientation or device), the scoreboard uses a system toolbar and the entry sheet uses the system grabber, and two open windows of the app stay in sync. CI moves to the Xcode 27 runner. On a normal tall iPhone the app looks and works as before, apart from the toolbar and grabber.

### How to test
1. Run the app on the **iPhone 17** simulator (iOS 27). Start a game with 4 players.
   - The top bar shows **End Game** and **Undo** as glass buttons with both words and symbols, and **Round 1** as the title. Undo is dimmed until a round is recorded.
   - Open the entry sheet: the system grabber replaces the old drag handle; the layout is otherwise unchanged. Tap a lower row: it scrolls into view.
2. Run on the **iPad Pro 11-inch** simulator (iOS 27), portrait and landscape.
   - The entry sheet is a centred panel, 720pt wide: player rows on the left, "who ended", numpad and Confirm on the right. Its height follows the player count (try 2 and 8 players; all eight rows fit).
   - In landscape the win screen uses a one-line header (trophy beside the name) with **New Game — Same Players** and **Start Fresh** side by side. In portrait it is unchanged.
3. On iPad, turn on windowed apps and drag the window short and wide, then tall and narrow. Each screen switches arrangement live; scores already typed into the entry sheet are kept across the switch.
4. Two windows on iPad: open a second window of the app on the same game. Finish the game in one window (enter 100 for someone). Both windows show the win screen, and any entry sheet open in the other window closes.
5. Accessibility spot checks: Larger Accessibility Sizes (AX3) in the iPad panel keeps Confirm inside the panel; Reduce Motion makes layout switches and row scrolling instant; Increase Contrast uses the high-contrast brand on the toolbar and the Start Fresh button.

### Notes for reviewer
- **One rule for layout:** `LayoutMode` in `Theme.swift` classifies the space a screen is given: *wide* (≥ 560pt wide and either < 575pt tall or width ÷ height ≥ 1.2), *short* (< 575pt tall), else *tall*. Screens read it through `onAvailableSize(update:_:)`, which fills the offered space, ignores the keyboard (typing a name never reflows setup), applies the first reading instantly and animates later switches ease-out 240ms (instant with Reduce Motion).
- **Measurement gotchas found while verifying:** (1) the reader must take exactly the offered size (`minWidth/minHeight: 0` with `max: .infinity`); otherwise large Dynamic Type content that overflows inflates the reading and can flip the layout. (2) The keyboard is ignored by measuring *inside* `.ignoresSafeArea(.keyboard)`; measuring outside it reads the keyboard-shrunk height.
- **Toolbar labels:** iOS 27 collapses a toolbar `Label` to its icon even with `.labelStyle(.titleAndIcon)`, so each button's label is an `HStack` of symbol + title (symbol hidden from VoiceOver). The system sizes the glass capsule to the words, so nothing truncates.
- **Entry sheet sizing:** on iOS 18+ the sheet uses `.presentationSizing(.fitted)` with an ideal 720 × (430/480/530/580 for 2/4/6/8 players). On iOS 17 the default form sheet and stacked layout are kept. All entry state stays in the sheet's `@State`, so a live mode switch keeps what's been typed.
- **Win screen actions:** paired on one line in short/wide windows; in a narrow short window the decorative arrow icon is dropped first, and if a long language or large text still doesn't fit, the buttons stack rather than wrap.
- **Two windows:** the win screen is presented from `session.isGameOver` and the entry sheet hides when the game is over, so every window agrees. `GameSession.commitRound` now ignores rounds after game over (the "no scoring past game over" rule), covered by a new unit test.
- **CI:** `runs-on: xcode-27` (no `xcode-select` pin) and destination `name=iPhone 17`. If the preview image is flaky, `macos-26` is the fallback.
- **Out of scope, unchanged:** app icon, widgets, Live Activities, App Intents, Duo fold (`ReservedRegion`) handling, landscape on standard iPhones, Swift 6.
- **Known limitations:** at AX3 and above, "who ended" chip names truncate in the two-column grid (same chip as before); at AX3 in a window only ~460pt tall, the win screen's stacked New Game label truncates for lack of height. The iPhone Duo simulator needs Xcode 27.1 (beta), so Duo was checked with a Duo-sized frame, not the device simulator.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
