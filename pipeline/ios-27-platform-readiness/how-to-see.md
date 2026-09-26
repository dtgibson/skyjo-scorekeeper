# Seeing iOS 27 Platform Readiness locally

You'll run the app in Xcode's simulator: first as an iPhone, then as an iPad
(tall, wide, and resized), with a small and a large group of players.

## 1. Open the project and run it on an iPhone

1. Open Xcode.
2. Choose **File → Open…** and open
   `SkyjoScorekeeper/SkyjoScorekeeper.xcodeproj` in your project folder.
3. At the top of the Xcode window, next to the ▶ (Run) button, make sure the
   scheme says **SkyjoScorekeeper**.
4. Click the device name beside it and choose **iPhone 17** (under iOS 27).
5. Press **⌘R** (or click ▶). The Simulator opens and the app launches.

**What to look for**
- Setup looks exactly as before. Enter two names and tap **Start Game**.
- The top of the scoreboard now has two glass buttons, **✕ End Game** on the
  left and **↩ Undo** on the right, with **Round 1** in the middle. Undo is
  dimmed until you record a round.
- Tap **Enter Round 1 Scores**. The sheet has the standard iOS grabber at the
  top (a small grey bar) instead of the old custom handle. Everything else is
  where it was.

## 2. Try 2 players and 8 players

1. Tap **End Game**, then **End Game** again to confirm. You're back at setup.
2. Tap **Add Player** until there are 8 names (the button disappears at 8), fill
   them in, and start the game.
3. Open the entry sheet. The list scrolls as before. Tap one of the lower
   players: the list scrolls so that row sits in view.

## 3. See it on an iPad (tall and wide)

1. Stop the app (**⌘.**), pick **iPad Pro 11-inch (M5)** (iOS 27) as the
   device, and press **⌘R**.
2. Start a game with 4 players and open the entry sheet.
   - It's now a centred panel: player rows on the left; "Who ended the round?",
     the number pad and **Confirm** on the right. The keys are taller, filling
     the column.
3. Rotate the iPad: in the Simulator menu choose **Device → Rotate Left**
   (**⌘←**). The panel stays the same side-by-side layout.
4. Go back to setup and start again with **2 players**, then with **8 players**.
   The panel is shorter for 2 (rows centred beside the keypad) and taller for 8
   (all eight rows showing).

## 4. Resize an iPad window

1. On the iPad simulator, open the **Settings** app → **Multitasking &
   Gestures** and choose **Windowed Apps**.
2. Open the app again. It now sits in a window you can resize by dragging its
   bottom-right corner.
3. Drag the window **short and wide**, then **tall and narrow**, and watch:
   - **Entry sheet:** switches between side-by-side and stacked. Type a few
     scores first; they stay put when the layout switches.
   - **Setup:** when the window is short, the title shrinks, "Who's playing
     today?" hides and "N players ready" moves beside **Start Game**.

## 5. See the win screen

1. Start a game (any number of players) and open the entry sheet.
2. Give one player **100**, fill in everyone else, pick who ended the round, and
   tap **Confirm**.
   - On a tall screen (iPhone, iPad portrait) the win screen looks as before.
   - On iPad landscape or a short window, the trophy sits beside the winner's
     name on one line, and **New Game — Same Players** and **Start Fresh** sit
     side by side, leaving more room for the standings.

## 6. Two windows stay in sync (iPad, windowed apps on)

1. With a game in progress, open a second window of the app (long-press the
   app's icon in the Dock and choose to show all windows, then add a new
   window; the exact gesture varies slightly between iPadOS versions).
2. Both windows show the same game. Finish the game in one window (step 5).
   Both windows show the win screen, and an entry sheet left open in the other
   window closes on its own.

## Optional accessibility checks

In the simulator's **Settings → Accessibility**:
- **Display & Text Size → Larger Text** (turn on Larger Accessibility Sizes,
  drag near the middle): on iPad the entry panel still keeps **Confirm** inside
  it; the "who ended" list scrolls instead.
- **Motion → Reduce Motion**: layout switches and row scrolling happen
  instantly, with no animation.
- **Display & Text Size → Increase Contrast**: the toolbar buttons and the
  **Start Fresh** button use the darker indigo.

## Not in the simulator

- **iPhone Duo** needs Xcode 27.1 (still beta). The iPad in landscape and a
  short-and-wide iPad window show the same arrangement you'll get on Duo.
- **iPhone Mirroring** needs a real iPhone and a Mac. A short, narrow iPad
  window is the closest simulator stand-in.
