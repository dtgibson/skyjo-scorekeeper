#!/bin/zsh
# usage: statusbar.sh <udid> -- clean 9:41 status bar. The time goes last: a later
# override call re-renders the date with the wrong weekday (simctl quirk).
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
xcrun simctl status_bar $1 clear
xcrun simctl status_bar $1 override --batteryState discharging --batteryLevel 100 --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --dataNetwork wifi --operatorName ""
xcrun simctl status_bar $1 override --time "2026-10-27T09:41:00.000-07:00"
