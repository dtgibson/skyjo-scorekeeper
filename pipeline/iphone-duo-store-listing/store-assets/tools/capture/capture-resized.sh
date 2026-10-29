#!/bin/zsh
# usage: capture-resized.sh <duo-udid> <setup|board|entry|win> <WxH points> <out.png>
# iPhone Duo inner display without Device Hub: launches the demo screen, moves the
# app to the simulator's "Resizable" display at exactly WxH points with
# `devicectl device appResize`, and screenshots that display (screen 5).
# env: FOLD_X  stand-in fold centre in window points (sideways shots: 475.5)
#      NO_OCC  1 = the app ignores the occlusion regions the simulator copies
#              from the outer display into the resized window
#      SETTLE  seconds before the shot (default 8)
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
udid=$1; screen=$2; size=$3; out=$4
BUNDLE=com.dtgibson.SkyjoScorekeeper
xcrun simctl terminate $udid $BUNDLE >/dev/null 2>&1
env SIMCTL_CHILD_DEMO_SCREEN=$screen ${FOLD_X:+SIMCTL_CHILD_DEMO_FOLD_X=$FOLD_X} ${NO_OCC:+SIMCTL_CHILD_DEMO_NO_OCCLUSIONS=1} \
  xcrun simctl launch $udid $BUNDLE >/dev/null || exit 1
sleep 3
xcrun devicectl device appResize start --device $udid --preferred-size $size >/dev/null 2>&1 &
rpid=$!
sleep ${SETTLE:-8}
xcrun simctl io $udid screenshot --type=png --display=5 "$out"
kill -INT $rpid 2>/dev/null; wait $rpid 2>/dev/null
