# Store asset tools

How the 1.7.1 App Store screenshots and product page header were made, so they can be made
again. Everything here runs on a Mac with Xcode 27.1 at `/Applications/Xcode.app`.

| Path | What it is |
|---|---|
| `compose.swift` | Puts each raw capture into Apple's bezel on the indigo background, with its caption, at the exact App Store size (no alpha, sRGB). Also builds the product page header and its alternative. |
| `fetch-bezels.sh` | Downloads Apple's product bezels into `~/Library/Caches/skyjo-store-bezels` (outside the repo). |
| `captures/` | The raw simulator captures the images are built from. |
| `capture/` | The demo-data patch and the scripts that took those captures. |
| `checks/` | Reviewer copies of the two headers with Apple's art safe area drawn on. Not for upload. |

## Rebuild the images from the captures

```sh
cd pipeline/iphone-duo-store-listing/store-assets
tools/fetch-bezels.sh                      # once; about 600 MB of downloads
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun swiftc -O tools/compose.swift -o /tmp/skyjo-compose
/tmp/skyjo-compose tools/captures ~/Library/Caches/skyjo-store-bezels .
```

It prints each image's caption lines and where the device sits, then `OK`. A `NOTE` is
informational; a `PROBLEM` (caption touching the device, devices overlapping, more than 12px past
a margin) exits non-zero. Check the results with:

```sh
find . -name '*.png' -not -path './tools/*' -exec sips -g pixelWidth -g pixelHeight -g hasAlpha {} \;
```

**Why the bezels aren't in the repo:** Apple's Design Resources licence doesn't allow the bezel
files to be redistributed on their own, and this repo is public. Finished screenshots (the app
inside the bezel) are the use Apple intends. The colours used are iPhone 18 Pro Max Black,
iPad Pro 13" (M5) Silver and iPhone Duo Star White, the same art as the approved mockup.

## Retake the captures

The demo data (Shawn, Mike, David, Elena, Phoebe, the May 2026 game) comes from launch hooks
that exist only in a scratch copy of the app. **Never apply `capture/demo-hooks.patch` to the
real source.**

1. Copy the repo somewhere outside it, apply the patch, build for the simulator:
   ```sh
   rsync -a --exclude .git --exclude pipeline ./ /tmp/skyjo-demo/
   cd /tmp/skyjo-demo && patch -p1 < <repo>/pipeline/iphone-duo-store-listing/store-assets/tools/capture/demo-hooks.patch
   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild build \
     -project SkyjoScorekeeper/SkyjoScorekeeper.xcodeproj -scheme SkyjoScorekeeper \
     -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/skyjo-demo-dd \
     CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
   ```
   The hooks: `DEMO_SCREEN=setup|board|entry|win` opens that screen with the demo game;
   `DEMO_FOLD_X` adds a stand-in 24pt fold at that x (window points); `DEMO_NO_OCCLUSIONS=1`
   makes the app ignore occlusion regions.
2. Create simulators: iPhone 17 Pro Max and iPad Pro 13-inch (M5) on iOS 27.0, iPhone Duo on
   iOS 27.1. Run `capture/prep-sim.sh <udid>` on each (12-hour clock, 9:41, full battery,
   three Wi-Fi bars; it reboots the simulator), then install the app with
   `xcrun simctl install <udid> /tmp/skyjo-demo-dd/Build/Products/Debug-iphonesimulator/SkyjoScorekeeper.app`.
   Re-run `capture/statusbar.sh <udid>` after any later reboot.
3. Capture:
   - iPhone and iPad: `capture/capture.sh <udid> board|entry|win|setup out.png`. For the
     dark shot, `xcrun simctl ui <udid> appearance dark` first.
   - iPhone Duo outer display (closed): add `--display=1` (screen 1 is the 1398×2034 outer
     display; without it you get the dark inner one).
   - iPhone Duo inner display: `capture/capture-resized.sh <udid> <screen> 669x951 out.png`
     for upright, and `FOLD_X=475.5 NO_OCC=1 capture/capture-resized.sh <udid> <screen> 951x669 out.png`
     for sideways (two pages).

### How the iPhone Duo inner display was captured (read this before reusing the images)

The simulator's poses (open, half-open, tabletop) can only be set in Xcode's Device Hub, which
needs the Mac's screen unlocked and can't be scripted. Powering the outer display off with
`simctl io … screenConfig` shuts the simulator down. So the inner display was captured with
`devicectl device appResize`, which moves the app to a separate display at an exact size:

- **Upright (669×951pt):** the app's tall layout, exactly as it lays out at that size. A fold
  running side to side doesn't change these two screens. Differences from a real open phone:
  no status bar, and **Undo sits about 144pt in from the right edge**. The simulator copies the
  outer display's camera region into the resized window at the same offset from its top-right
  corner (602, 29, 37×37pt), and the system toolbar steps Undo around it. Apple's inner-display
  bezel shows no camera there.
- **Sideways (951×669pt), two pages:** the two-page layout appears only when the system reports
  a fold, and the simulator reports none here. These captures come from the scratch build with
  a **stand-in 24pt fold at the window's centre**, the same method the iPhone Duo optimization
  build used. The fold is fed through the app's real `AvailableSpace` reader, so every layout
  decision is the shipped code's. The app also ignored the outer-display regions the simulator
  copies into the window (`NO_OCC=1`), which would otherwise push the left page down by up to
  174pt. The real fold's width and position are unconfirmed.

Retake the four inner-display shots on a real iPhone Duo, or in Device Hub, when one is
available.
