#!/bin/zsh
# usage: capture.sh <udid> <setup|board|entry|win> <out.png> [screenshot args, e.g. --display=1]
# Launches the demo build on a demo screen and screenshots the device display.
# env: SETTLE seconds to wait before the shot (default 4)
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
udid=$1; screen=$2; out=$3; shift 3
BUNDLE=com.dtgibson.SkyjoScorekeeper
xcrun simctl terminate $udid $BUNDLE >/dev/null 2>&1
SIMCTL_CHILD_DEMO_SCREEN=$screen xcrun simctl launch $udid $BUNDLE >/dev/null || exit 1
sleep ${SETTLE:-4}
xcrun simctl io $udid screenshot --type=png "$@" "$out"
