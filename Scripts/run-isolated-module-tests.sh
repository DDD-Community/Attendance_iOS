#!/usr/bin/env bash

set -uo pipefail

readonly APP_SCHEME="${APP_SCHEME:-DDDAttendance}"
readonly CONFIGURATION="${CONFIGURATION:-Stage}"
readonly SIMULATOR_DESTINATION="${SIMULATOR_DESTINATION:?SIMULATOR_DESTINATION is required}"
readonly CI_DERIVED_DATA="${CI_DERIVED_DATA:?CI_DERIVED_DATA is required}"
readonly RESULTS_DIRECTORY="${RESULTS_DIRECTORY:-TestResults}"
readonly MERGED_RESULT_BUNDLE="${MERGED_RESULT_BUNDLE:-TestResults.xcresult}"
readonly LOGS_DIRECTORY="${LOGS_DIRECTORY:-TestLogs}"

compilation_cache_enabled="${XCODE_COMPILATION_CACHE_ENABLED:-NO}"

declare -a test_schemes=()
declare -a result_bundles=()
declare -a failed_schemes=()

while IFS= read -r tests_directory; do
  project_directory="$(dirname "$tests_directory")"
  module_name="$(basename "$project_directory")"

  if [[ "$module_name" == "App" ]]; then
    test_schemes+=("$APP_SCHEME")
  else
    test_schemes+=("$module_name")
  fi
done < <(find Projects -type d -name Tests -print | sort)

if [[ ${#test_schemes[@]} -eq 0 ]]; then
  echo "테스트 스킴을 찾지 못했습니다."
  exit 1
fi

rm -rf "$RESULTS_DIRECTORY" "$MERGED_RESULT_BUNDLE" "$LOGS_DIRECTORY"
mkdir -p "$RESULTS_DIRECTORY" "$CI_DERIVED_DATA" "$LOGS_DIRECTORY"

for scheme in "${test_schemes[@]}"; do
  safe_scheme="${scheme//[^[:alnum:]_-]/_}"
  derived_data="$CI_DERIVED_DATA/$safe_scheme"
  result_bundle="$RESULTS_DIRECTORY/$safe_scheme.xcresult"
  build_log="$LOGS_DIRECTORY/$safe_scheme.log"

  # Xcode 26.3은 host-less 테스트가 Sharing.framework가 있는 공용 Products를 보면
  # XCTest의 LocalStatusKit 클래스 탐색 중 충돌한다. 스킴별 Products를 격리한다.
  mkdir -p "$derived_data"
  rm -rf \
    "$derived_data/Build" \
    "$derived_data/Index.noindex" \
    "$derived_data/Logs" \
    "$derived_data/SourcePackages" \
    "$derived_data/info.plist" \
    "$result_bundle"

  echo "▶︎ $scheme 테스트 시작"
  if mise exec -- tuist test "$scheme" \
    --configuration "$CONFIGURATION" \
    --no-selective-testing \
    --inspect-mode remote \
    --result-bundle-path "$result_bundle" \
    --path "$PWD" \
    -- \
    -destination "$SIMULATOR_DESTINATION" \
    -derivedDataPath "$derived_data" \
    -enableCodeCoverage YES \
    -retry-tests-on-failure \
    -test-iterations 3 \
    ONLY_ACTIVE_ARCH=YES \
    COMPILATION_CACHE_ENABLE_CACHING="$compilation_cache_enabled" 2>&1 | tee "$build_log"; then
    echo "✓ $scheme 테스트 성공"
  else
    echo "✗ $scheme 테스트 실패"
    failed_schemes+=("$scheme")
  fi

  # Tuist 원격 CAS가 5xx를 반환하면 Xcode는 소스 컴파일로 복구하지만 같은 경고를
  # 다음 타깃에서도 반복한다. 해당 실행의 남은 모듈만 캐시를 꺼 불필요한 재시도를 막는다.
  if [[ "$compilation_cache_enabled" == "YES" ]] && \
    grep -Eq 'CAS error:.*Tuist response of 5[0-9]{2}' "$build_log"; then
    compilation_cache_enabled="NO"
    echo "Tuist CAS 서버 오류를 감지해 남은 모듈은 compilation cache 없이 실행합니다."
  fi

  if [[ -d "$result_bundle" ]]; then
    result_bundles+=("$result_bundle")
  fi
done

if [[ ${#result_bundles[@]} -eq 0 ]]; then
  echo "병합할 xcresult가 없습니다."
  exit 1
fi

if [[ ${#result_bundles[@]} -eq 1 ]]; then
  ditto "${result_bundles[0]}" "$MERGED_RESULT_BUNDLE"
else
  xcrun xcresulttool merge \
    --output-path "$MERGED_RESULT_BUNDLE" \
    "${result_bundles[@]}"
fi

# 병합본에 각 테스트 실행과 진단이 모두 포함되므로 중복 번들은 즉시 정리한다.
rm -rf "$RESULTS_DIRECTORY"

# Tuist에는 분리 실행한 결과를 하나로 합쳐 한 테스트 실행으로 업로드한다.
mise exec -- tuist inspect test "$MERGED_RESULT_BUNDLE" \
  --mode remote \
  --path "$PWD" | tee TuistTestRun.log

if [[ ${#failed_schemes[@]} -gt 0 ]]; then
  echo "실패한 테스트 스킴: ${failed_schemes[*]}"
  exit 1
fi

echo "전체 ${#test_schemes[@]}개 모듈 테스트가 성공했습니다."
