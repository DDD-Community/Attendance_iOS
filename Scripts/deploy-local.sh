#!/usr/bin/env bash
# CI(ios-deploy.yml)와 같은 순서로 로컬에서 배포한다.
#   Scripts/deploy-local.sh release  # App Store 업로드 후 심사 제출
#   Scripts/deploy-local.sh qa       # TestFlight 업로드
# 비대화형 셸에는 rbenv shim이 PATH에 없어 Homebrew Ruby가 잡힐 수 있으므로
# CI처럼 rbenv shim을 PATH 맨 앞에 두고 .ruby-version과 일치하는지 확인한다.
# 배포 자격 증명은 fastlane/.env 에서 읽는다.
set -euo pipefail

readonly lane="${1:-}"
if [[ "$lane" != "release" && "$lane" != "qa" ]]; then
  echo "사용법: $0 release|qa" >&2
  exit 64
fi

cd "$(dirname "$0")/.."

export PATH="$HOME/.rbenv/shims:$HOME/.local/share/mise/shims:/opt/homebrew/bin:$PATH"
expected_ruby="$(cat .ruby-version)"
actual_ruby="$(ruby -e 'print RUBY_VERSION' 2>/dev/null || true)"
if [[ "$actual_ruby" != "$expected_ruby" ]]; then
  echo "Ruby $expected_ruby 가 필요합니다. 현재: ${actual_ruby:-없음} ($(command -v ruby || echo 'ruby 없음'))" >&2
  exit 1
fi

if [[ ! -f fastlane/.env ]]; then
  echo "fastlane/.env 가 없습니다. 배포 자격 증명을 먼저 준비해 주세요." >&2
  exit 1
fi
set -a
# shellcheck disable=SC1091
source fastlane/.env
set +a
export TUIST_RELEASE_BUILD=1 LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export FASTLANE_SKIP_UPDATE_CHECK=1 FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=600

tuist install
tuist generate --no-open --cache-profile none

if [[ "$lane" == "qa" ]]; then
  RELEASE_NOTES="$(git log -1 --pretty=%s)" bundle exec fastlane ios QA
  exit 0
fi

version_file="Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/Extension+String.swift"
version="$(sed -nE 's/.*appVersion\(version: String = "([0-9.]+)"\).*/\1/p' "$version_file" | head -1)"
test -n "$version" || { echo "appVersion 추출 실패: $version_file" >&2; exit 1; }

bundle exec fastlane ios release
bundle exec fastlane ios submit_for_review version:"$version"
