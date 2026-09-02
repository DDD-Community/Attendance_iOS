#!/usr/bin/env bash

set -euo pipefail

readonly TEST_SCHEME="${TEST_SCHEME:-DDDAttendance-Stage}"
readonly CONFIGURATION="${CONFIGURATION:-Stage}"
readonly SIMULATOR_DESTINATION="${SIMULATOR_DESTINATION:?SIMULATOR_DESTINATION is required}"
readonly CI_DERIVED_DATA="${CI_DERIVED_DATA:?CI_DERIVED_DATA is required}"
readonly RESULT_BUNDLE="${RESULT_BUNDLE:-TestResults.xcresult}"

compilation_cache_enabled="${XCODE_COMPILATION_CACHE_ENABLED:-NO}"

rm -rf "$RESULT_BUNDLE" TuistTestRun.log

# 모든 테스트 타깃은 DDDTestHost 또는 DDDTCAHost를 사용한다.
# 하나의 Stage workspace scheme으로 실행하면 SPM/TCA 그래프를 한 번만 빌드하면서도
# xcresult에 모듈별 테스트 케이스와 커버리지가 함께 기록된다.
#
# 선택적 테스트는 켜둔다. 변경되지 않은 모듈은 실행을 건너뛰므로
# xcresult 에서도 빠지고, PR 커버리지는 그 PR 이 건드린 범위 기준으로 집계된다.
# 커버리지 수치가 PR 마다 출렁이는 것은 이 선택의 결과이지 회귀가 아니다.
mise exec -- tuist test "$TEST_SCHEME" \
  --configuration "$CONFIGURATION" \
  --inspect-mode remote \
  --result-bundle-path "$RESULT_BUNDLE" \
  --path "$PWD" \
  -- \
  -destination "$SIMULATOR_DESTINATION" \
  -derivedDataPath "$CI_DERIVED_DATA" \
  -enableCodeCoverage YES \
  -retry-tests-on-failure \
  -test-iterations 2 \
  -collect-test-diagnostics never \
  ONLY_ACTIVE_ARCH=YES \
  COMPILATION_CACHE_ENABLE_CACHING="$compilation_cache_enabled" \
  2>&1 | tee TuistTestRun.log

echo "전체 모듈 테스트를 $TEST_SCHEME 스킴으로 한 번에 실행했습니다."
