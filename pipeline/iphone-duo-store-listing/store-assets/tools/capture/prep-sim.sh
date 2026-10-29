#!/bin/zsh
# usage: prep-sim.sh <udid>  -- 12-hour clock, reboot, clean 9:41 status bar, light mode
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
u=$1
xcrun simctl spawn $u defaults write -g AppleICUForce24HourTime -bool false
xcrun simctl shutdown $u 2>/dev/null; xcrun simctl boot $u; xcrun simctl bootstatus $u -b >/dev/null
"${0:A:h}/statusbar.sh" $u
xcrun simctl ui $u appearance light
