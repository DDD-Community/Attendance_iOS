#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="$ROOT/.tools/appium-3.8.0"
if [ -e "$DEST" ]; then
  echo "Already exists: $DEST (not overwritten)" >&2
  exit 1
fi
mkdir -p "$DEST"
npm install --prefix "$DEST" --save-exact --no-audit --no-fund appium@3.8.0
export APPIUM_HOME="$DEST/home"
"$DEST/node_modules/.bin/appium" driver install xcuitest@12.18.1
"$DEST/node_modules/.bin/appium" --version
"$DEST/node_modules/.bin/appium" driver list --installed
