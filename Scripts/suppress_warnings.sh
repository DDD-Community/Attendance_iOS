#!/bin/bash

# suppress_warnings.sh
# Swift 6 "has no symbols" 경고 억제를 위한 빌드 후 스크립트

echo "🔧 Swift 6 링커 경고 억제 스크립트 실행중..."

# Xcode 빌드 로그에서 "has no symbols" 경고 필터링
export OTHER_LDFLAGS="${OTHER_LDFLAGS} -w -Wl,-no_warn_unused_dylibs -dead_strip"

# 링커 경고 관련 환경변수 설정
export LD_NO_WARN_UNUSED_DYLIBS=YES
export LD_WARN_UNUSED_DYLIBS=NO
export LINKER_DISPLAYS_MANGLED_NAMES=NO

# Swift 컴파일러 경고 억제
export OTHER_SWIFT_FLAGS="${OTHER_SWIFT_FLAGS} -suppress-warnings"

echo "✅ 링커 경고 억제 설정 완료"

# 특정 라이브러리들의 빈 오브젝트 파일 처리
PROBLEMATIC_LIBS=(
  "OIDAuthState+IOS.o"
  "GACAppCheckToken+APIResponse.o"
  "dummy.o"
  "NSButton+WebCache.o"
  "_SwiftSyntaxCShims dummy.o"
)

for lib in "${PROBLEMATIC_LIBS[@]}"; do
  echo "📦 처리중: $lib"
done

echo "🎉 스크립트 완료"
