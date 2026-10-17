#!/bin/bash
set -euo pipefail

# Keep the local snapshot outside the Actions checkout: checkout cleans ignored files.
LOCAL_CONFIG_ROOT="${IOS_LOCAL_CONFIG_ROOT:-$HOME/.config/ddd-attendance-ci}"
GOOGLE_RESOURCE="Projects/App/Resources/GoogleService-Info.plist"

# Validate every required fallback before changing the checkout.
if [[ -z "${CONFIG_TAR:-}" ]]; then
  for config in base Stage Prod; do
    if [[ ! -s "$LOCAL_CONFIG_ROOT/Config/$config.xcconfig" ]]; then
      echo "Missing runner-local Config/$config.xcconfig; prepare IOS_LOCAL_CONFIG_ROOT on this Mac." >&2
      exit 1
    fi
  done
fi
if [[ -z "${GOOGLE_PLIST:-}" && ! -s "$LOCAL_CONFIG_ROOT/$GOOGLE_RESOURCE" ]]; then
  echo "Missing runner-local GoogleService-Info.plist; prepare IOS_LOCAL_CONFIG_ROOT on this Mac." >&2
  exit 1
fi

if [[ -n "${CONFIG_TAR:-}" ]]; then
  CONFIG_ARCHIVE="$(mktemp "${RUNNER_TEMP:-/tmp}/ddd-ios-config.XXXXXX")"
  trap 'rm -f "$CONFIG_ARCHIVE"' EXIT
  printf '%s' "$CONFIG_TAR" | base64 --decode > "$CONFIG_ARCHIVE"
  tar tzf "$CONFIG_ARCHIVE" >/dev/null
  tar xzf "$CONFIG_ARCHIVE"
else
  mkdir -p Config
  cp -R "$LOCAL_CONFIG_ROOT/Config/." Config/
fi

mkdir -p Projects/App/Resources
if [[ -n "${GOOGLE_PLIST:-}" ]]; then
  printf '%s' "$GOOGLE_PLIST" | base64 --decode > "$GOOGLE_RESOURCE"
else
  cp "$LOCAL_CONFIG_ROOT/$GOOGLE_RESOURCE" "$GOOGLE_RESOURCE"
fi

for config in base Stage Prod; do test -s "Config/$config.xcconfig"; done
test -s "$GOOGLE_RESOURCE"
