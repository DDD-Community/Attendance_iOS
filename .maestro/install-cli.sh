#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="$ROOT/.tools/cli-2.11.0"
if [ -e "$DEST" ]; then
  echo "Already exists: $DEST (not overwritten)" >&2
  exit 1
fi
TEMP="$(mktemp -d "${TMPDIR:-/tmp}/attendance-maestro.XXXXXX")"
trap 'rm -rf "$TEMP"' EXIT
curl --fail --location --proto '=https' --tlsv1.2 \
  --connect-timeout 20 --max-time 240 \
  https://github.com/mobile-dev-inc/Maestro/releases/download/cli-2.11.0/maestro.zip \
  --output "$TEMP/maestro.zip"
EXPECTED=5384593cb4e7a106489e75a821d157dd43f4e438df6bc308b72e82c685e1283a
ACTUAL="$(shasum -a 256 "$TEMP/maestro.zip" | cut -d ' ' -f 1)"
if [ "$ACTUAL" != "$EXPECTED" ]; then
  echo 'Maestro SHA256 mismatch; installation stopped.' >&2
  exit 1
fi
unzip -q "$TEMP/maestro.zip" -d "$TEMP/unpacked"
test -f "$TEMP/unpacked/maestro/bin/maestro"
mkdir -p "$ROOT/.tools"
mv "$TEMP/unpacked/maestro" "$DEST"
printf 'Installed verified Maestro 2.11.0: %s\n' "$DEST"
