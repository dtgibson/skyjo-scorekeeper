#!/bin/zsh
# Downloads Apple's product bezels (Design Resources) and copies the five the
# store screenshots use into a cache folder OUTSIDE the repo. Apple's Design
# Resources licence does not allow redistributing the bezel files themselves,
# so they are never committed; only finished screenshots are.
#
# usage: fetch-bezels.sh [bezel-dir] [download-dir]
#   bezel-dir     default ~/Library/Caches/skyjo-store-bezels
#   download-dir  default a new temp folder; reused if the .dmg files are already there
set -euo pipefail
OUT=${1:-$HOME/Library/Caches/skyjo-store-bezels}
WORK=${2:-$(mktemp -d)}
CDN=https://devimages-cdn.apple.com/design/resources/download
mkdir -p "$OUT"

fetch() {  # <dmg name> <subfolder>
  mkdir -p "$WORK/$2"
  [[ -f "$WORK/$2/$1" ]] || curl -fSL --retry 2 -o "$WORK/$2/$1" "$CDN/$1"
}
mount_dmg() {  # <dmg path> <mount point>; the licence prompt is accepted non-interactively
  mkdir -p "$2"
  PAGER=cat hdiutil attach -readonly -nobrowse -noautoopen -mountpoint "$2" "$1" < <(yes) >/dev/null 2>&1
  [[ -d "$2/PNG" ]] || { echo "could not mount $1" >&2; exit 1; }
}

fetch "Bezel-iPhone-18.dmg" iphone
fetch "Bezel-iPad-Pro-(M5).dmg" ipad
fetch "Bezel-iPhone-Duo.dmg" duo

MNT=$(mktemp -d)
mount_dmg "$WORK/iphone/Bezel-iPhone-18.dmg" "$MNT/iphone"
mount_dmg "$WORK/ipad/Bezel-iPad-Pro-(M5).dmg" "$MNT/ipad"
mount_dmg "$WORK/duo/Bezel-iPhone-Duo.dmg" "$MNT/duo"
trap 'for m in iphone ipad duo; do hdiutil detach -quiet "$MNT/$m" 2>/dev/null || true; done' EXIT

cp "$MNT/iphone/PNG/iPhone 18 Pro Max/iPhone 18 Pro Max - Black - Portrait.png" "$OUT/iphone-18-pro-max-portrait.png"
cp "$MNT/ipad/PNG/iPad Pro (M5) 13\" - Silver - Portrait.png"                     "$OUT/ipad-pro-13-portrait.png"
cp "$MNT/duo/PNG/iPhone Duo - Star White - Outer Closed Portrait.png"             "$OUT/duo-outer-closed.png"
cp "$MNT/duo/PNG/iPhone Duo - Star White - Inner Open Portrait.png"               "$OUT/duo-inner-portrait.png"
cp "$MNT/duo/PNG/iPhone Duo - Star White - Inner Open Landscape.png"              "$OUT/duo-inner-landscape.png"
echo "Bezels ready in $OUT"
