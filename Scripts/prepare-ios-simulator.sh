#!/usr/bin/env bash

set -euo pipefail

readonly destination="${SIMULATOR_DESTINATION:?SIMULATOR_DESTINATION is required}"
readonly simulator_udid="${destination##*,id=}"

if [[ -z "$simulator_udid" || "$simulator_udid" == "$destination" ]]; then
  echo "시뮬레이터 destination에서 UDID를 찾을 수 없습니다: $destination" >&2
  exit 1
fi

# 이미 Booted 상태면 boot는 실패할 수 있으므로 무시하고, bootstatus와 spawn으로
# CoreSimulator가 actool의 AssetCatalogSimulatorAgent를 실행할 준비가 됐는지 확인한다.
xcrun simctl boot "$simulator_udid" 2>/dev/null || true
xcrun simctl bootstatus "$simulator_udid" -b
xcrun simctl spawn "$simulator_udid" /usr/bin/true

echo "CI 시뮬레이터가 CoreSimulator 요청을 처리할 준비가 됐습니다: $simulator_udid"
