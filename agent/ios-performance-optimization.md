# iOS 성능 최적화 통합 시스템

DDDAttendance 프로젝트를 위한 **2개의 전문 성능 최적화 스킬** 통합 활용 가이드

## ⚠️ 필수 서브에이전트 호출 규칙

**🔴 다음 상황에서는 반드시 서브에이전트를 호출해야 합니다:**

### 1. TCA 관련 문제 (필수)
- **ifCaseLet 오류**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출
- **Effect 누수/취소 문제**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출  
- **상태 관리 이슈**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출

### 2. SwiftUI 성능 문제 (필수)
- **UI 렌더링 지연**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출
- **메모리 누수**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출
- **스크롤 성능**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출

### 3. 빌드/네비게이션 문제 (필수)  
- **TCAFlow 오류**: 반드시 `@ios-performance-optimizer` 호출
- **WeaveDI 통합 문제**: 반드시 두 스킬 모두 호출
- **Tuist 빌드 시간**: 반드시 `@ios-performance-optimizer` 자동 최적화

### 4. 빌드 오류/컴파일 문제 (필수)
- **Cannot infer contextual base**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출
- **Extensions must not contain stored properties**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출  
- **Non-static property declared inside an extension**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출
- **Type annotation missing**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출
- **Referencing subscript requires wrapper 'Shared'**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출
- **No candidates produce the expected contextual result type**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출
- **SourceKit error**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출
- **빌드 실패/컴파일 에러**: 반드시 `@ios-performance-optimizer` + `@ios-performance-pfw` 동시 호출

### 5. 자동 호출 키워드
다음 키워드가 언급되면 **무조건 서브에이전트 호출**:
- `ifCaseLet`, `TCA`, `Effect`, `메모리 누수`, `성능`, `최적화`
- `SwiftUI`, `렌더링`, `빌드 시간`, `TCAFlow`, `WeaveDI`
- `Cannot infer`, `Extensions must not`, `Type annotation missing`
- `빌드 오류`, `컴파일 에러`, `SourceKit error`

**🚨 중요: 수동으로 코드를 직접 수정하기 전에 반드시 서브에이전트를 먼저 호출하세요!**

## 🎯 사용 가능한 스킬

### 1. ios-performance-optimizer 
**PFW 철학 통합 자동화 시스템 (v4.0)**
- 🎯 **PFW 우선**: Point-Free Workshop 단순성 원칙 최우선 적용
- 📊 **12개 서브에이전트 동시 실행** + PFW 패턴 통합 분석
- 🔧 타입 안전한 상태 검증 자동 구현 (`switch (action, state)`)
- 🚀 **TCAFlow & WeaveDI 3.4.0 전문** + PFW 철학 조화
- 🚫 **v3.0 복잡성 제거**: 3-6개 핵심 CancelID만 사용 (40개 차단 시스템 제거)
- 🔨 빌드 시스템 통합 (Tuist/Xcode) + PFW 베스트 프랙티스

```bash
@ios-performance-optimizer
```

### 2. ios-performance-pfw
**Point-Free Workshop 전문**
- 🏗️ TCA 아키텍처 최적화
- 📱 SwiftUI 성능 패턴
- 🧭 Swift Navigation 통합
- 🔍 PFW 라이브러리 전문

```bash
@ios-performance-pfw
```

### 3. swiftui-uikit-interop
**SwiftUI ↔ UIKit 상호 운용성 전문**
- 🎨 UIHostingController 최적화
- 🔗 UIViewRepresentable 성능 패턴
- 📱 SwiftUI에서 UIKit 컴포넌트 활용
- ⚡ 메모리 효율적인 View 브리징

```bash
@swiftui-uikit-interop
```

## 🎛️ 상황별 최적 스킬 선택

### 🔧 PFW 철학 기반 자동 최적화 (v4.0)
```bash
# PFW 패턴 우선 전체 프로젝트 최적화
@ios-performance-optimizer "PFW 단순성 원칙으로 DDDAttendance 최적화해줘 - 3개 핵심 CancelID만 사용"

# TCAFlow + PFW 패턴 마이그레이션 
@ios-performance-optimizer "PFW 철학 기반 TCAFlow 마이그레이션 - 복잡한 Effect 취소 금지"

# 타입 안전 상태 검증 자동 구현
@ios-performance-optimizer "switch (action, state) 패턴으로 ifCaseLet 오류 해결 - v3.0 복잡성 제거"
```

### 🏗️ 아키텍처 분석이 필요한 경우  
```bash
# TCA 패턴 분석
@ios-performance-pfw "HomeFeature TCA 성능 분석해줘"

# SwiftUI 성능 최적화
@ios-performance-pfw "LazyVStack 적용 패턴 알려줘"

# Point-Free 라이브러리 활용
@ios-performance-pfw "IdentifiedArray 성능 최적화 방법"
```

## 🔄 협업 워크플로우

### 1단계: 분석 (ios-performance-pfw)
```bash
@ios-performance-pfw "HomeView 성능 분석하고 개선점 찾아줘"
```

### 2단계: 자동 적용 (ios-performance-optimizer)
```bash
@ios-performance-optimizer "분석 결과 기반으로 자동 최적화해줘"
```

### 3단계: 통합 검증
```bash
# 두 스킬 결과 통합 확인
@ios-performance-pfw "자동 최적화 후 TCA 패턴 검증해줘"
```

## 📊 기능별 비교표 (v4.0 업데이트)

| 기능 | ios-performance-optimizer v4.0 | ios-performance-pfw |
|------|------------------------|-------------------|
| **자동 코드 수정** | ✅ PFW 철학 기반 자동화 | ❌ 분석만 |
| **TCA 전문성** | 🚀 **PFW + TCAFlow 통합** | ⚡ **전통 TCA 패턴 + Navigation은 TCAFlow 특화** |
| **빌드 통합** | ✅ **Tuist/Xcode + PFW 자동** | ❌ 수동 |
| **Point-Free 라이브러리** | 🚀 **PFW 통합 전문가 수준** | ✅ 전문가 수준 |
| **승인 프로세스** | ✅ **PFW 기반 단계별 승인** | ❌ 즉시 제안 |
| **서브에이전트** | 🚀 **PFW 통합 12개 전문** | 🏗️ 단일 통합 |
| **단순성 원칙** | ✅ **3개 핵심 CancelID** | ✅ PFW 철학 준수 |
| **복잡성 제거** | ✅ **v3.0 과도한 취소 금지** | ✅ 단순 패턴 권장 |
| **타입 안전성** | 🚀 **자동 튜플 매칭 구현** | ✅ 이론적 분석 |

## 🎯 DDDAttendance 특화 사용법

### HomeView 스크롤 성능 이슈
```bash
# 1. PFW로 정확한 분석
@ios-performance-pfw "HomeView LazyVStack 성능 분석해줘"

# 2. 자동화 도구로 적용
@ios-performance-optimizer "LazyVStack 최적화 자동 적용해줘"
```

### TCA Store 메모리 누수
```bash
# 1. PFW로 아키텍처 검증
@ios-performance-pfw "ExploreFeature Effect 취소 패턴 분석해줘" 

# 2. 자동화로 수정
@ios-performance-optimizer "TCA Effect 메모리 누수 자동 수정해줘"
```

### 빌드 시간 최적화
```bash
# 1. PFW로 의존성 분석
@ios-performance-pfw "모듈 의존성 구조 분석해줘"

# 2. 자동화로 Tuist 최적화
@ios-performance-optimizer "Tuist 빌드 시간 자동 최적화해줘"
```

## 🚀 고급 활용 패턴

### 연속 호출 패턴
```bash
# A → B → A 패턴 (분석 → 적용 → 검증)
@ios-performance-pfw "전체 아키텍처 분석해줘"
# ↓ 
@ios-performance-optimizer "분석 기반 자동 최적화해줘"  
# ↓
@ios-performance-pfw "최적화 결과 TCA 패턴 검증해줘"
```

### 병렬 호출 패턴
```bash
# 동시에 다른 관점에서 분석
@ios-performance-pfw "SwiftUI 성능 분석해줘"
@ios-performance-optimizer "메모리 누수 자동 검사해줘"
```

## 📋 체크리스트

### 성능 최적화 전
- [ ] `@ios-performance-pfw`로 아키텍처 분석 완료
- [ ] 성능 병목 지점 식별 완료
- [ ] Point-Free 패턴 적용 가능성 확인

### 자동 최적화 시
- [ ] `@ios-performance-optimizer`로 자동 분석 실행
- [ ] 개선 계획 검토 및 승인
- [ ] 자동 코드 수정 완료

### 최적화 후
- [ ] `@ios-performance-pfw`로 패턴 검증
- [ ] 성능 개선 효과 측정
- [ ] 추가 최적화 필요성 검토

## 🔧 빌드 오류 해결 프로세스 (필수)
```bash
# 1단계: 빌드 오류 발생 시 두 에이전트 동시 호출
@ios-performance-optimizer "Cannot infer contextual base 빌드 오류 자동 수정해줘"
@ios-performance-pfw "Cannot infer contextual base TCA 패턴 분석해줘"

# 2단계: Swift 문법 및 Extension 문제 해결
@ios-performance-optimizer "Extension stored property 오류 자동 수정해줘"  
@ios-performance-pfw "Extension 패턴 및 TCA 베스트 프랙티스 분석해줘"

# 3단계: SourceKit 문제 및 Type annotation 해결
@ios-performance-optimizer "Type annotation missing 자동 수정해줘"
@ios-performance-pfw "Type inference 패턴 및 TCA 타입 분석해줘"

# 4단계: 두 에이전트 결과 비교 후 최적 솔루션 선택
# - 자동화 우선: @ios-performance-optimizer 결과가 완전히 작동하면 채택
# - 품질 우선: @ios-performance-pfw 분석이 더 나은 아키텍처를 제시하면 채택  
# - 하이브리드: 두 접근법의 장점을 결합한 최적 솔루션 도출
```

## 🔍 두 에이전트 결과 비교 및 최적 솔루션 선택 (필수)

### 비교 기준:
- **완성도**: 실제 작동하는 코드를 제공하는가?
- **아키텍처**: TCA/PFW 베스트 프랙티스를 따르는가?
- **성능**: 메모리 누수나 Effect 관리가 우수한가?
- **유지보수성**: 코드가 읽기 쉽고 확장 가능한가?

### 선택 전략:
```bash
# 1. @ios-performance-optimizer 우선 (빠른 해결)
- 완전 자동 수정 가능
- 즉시 빌드 성공
- 기본적인 TCA 패턴 준수

# 2. @ios-performance-pfw 우선 (품질 우선)  
- PFW 전문 패턴 제시
- 더 나은 아키텍처 설계
- 장기적 유지보수성 향상

# 3. 하이브리드 접근 (최적 솔루션)
- optimizer의 자동 수정 + pfw의 아키텍처 개선
- 두 접근법의 장점 결합
- 실용성과 품질의 균형
```

### 최종 결정 프로세스:
1. **두 에이전트 동시 호출**
2. **결과 비교 및 분석** 
3. **최적 솔루션 선택 및 적용**
4. **선택 이유 명시**

## 🎉 결론 (v4.0 업데이트)

**🚀 PFW 철학 통합으로 더욱 강력해진 최적 조합:**
1. **정확한 분석**: `@ios-performance-pfw`의 **Point-Free 전문성** + v4.0 이론적 뒷받침
2. **빠른 적용**: `@ios-performance-optimizer v4.0`의 **PFW 기반 자동화 시스템**
3. **품질 보증**: **PFW 철학을 공유**하는 두 스킬의 **완벽한 교차 검증**

**🎯 v4.0 핵심 개선:**
- ✅ **복잡성 제거**: v3.0의 40개 Effect 차단 → 3개 핵심 CancelID
- ✅ **PFW 우선**: performAtomicStateTransition 제거 → 단순 튜플 매칭
- ✅ **타입 안전**: 수동 검증 → 자동 `switch (action, state)` 구현

**DDDAttendance 프로젝트에서 PFW 철학이 통합된 이 두 스킬을 조합하면 iOS 성능 최적화의 완벽한 솔루션을 얻을 수 있습니다!** 🚀