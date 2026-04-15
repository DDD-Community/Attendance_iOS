# 🚀 iOS 성능 최적화 통합 가이드

TimeSpot 프로젝트를 위한 **2개의 전문 성능 최적화 스킬** 통합 활용 가이드

## 🎯 사용 가능한 스킬

### 1. ios-performance-optimizer 
**완전 자동화 시스템 (v2.3)**
- 📊 12개 서브에이전트 동시 실행
- 🔧 자동 코드 수정 + 승인 프로세스
- 🔨 빌드 시스템 통합 (Tuist/Xcode)
- 🚀 TCAFlow & WeaveDI 3.4.0 전문

### 2. ios-performance-pfw
**Point-Free Workshop 전문**
- 🏗️ TCA 아키텍처 최적화
- 📱 SwiftUI 성능 패턴
- 🧭 Swift Navigation 통합
- 🔍 PFW 라이브러리 전문

## 🎛️ 상황별 최적 스킬 선택

### 🔧 자동 최적화가 필요한 경우
```bash
# 전체 프로젝트 자동 최적화
@ios-performance-optimizer "TimeSpot 프로젝트 전체 최적화해줘"

# TCAFlow 마이그레이션 
@ios-performance-optimizer "TCACoordinator를 TCAFlow로 마이그레이션해줘"

# WeaveDI 3.4.0 적용
@ios-performance-optimizer "@DependencyConfiguration 패턴 적용해줘"
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

## 📊 기능별 비교표

| 기능 | ios-performance-optimizer | ios-performance-pfw |
|------|------------------------|-------------------|
| **자동 코드 수정** | ✅ 완전 자동화 | ❌ 분석만 |
| **TCA 전문성** | ⚡ TCAFlow 특화 | ⚡ 전통 TCA 패턴 |
| **빌드 통합** | ✅ Tuist/Xcode 자동 | ❌ 수동 |
| **Point-Free 라이브러리** | ⚠️ 기본 수준 | ✅ 전문가 수준 |
| **승인 프로세스** | ✅ 단계별 승인 | ❌ 즉시 제안 |
| **서브에이전트** | 🚀 12개 전문 | 🏗️ 단일 통합 |
| **WeaveDI 3.4.0** | 🚀 혁신 패턴 | ✅ 지원 |

## 🎯 TimeSpot 특화 사용법

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

## 🎉 결론

**🔥 최대 효과를 위한 조합:**
1. **정확한 분석**: `@ios-performance-pfw`의 Point-Free 전문성
2. **빠른 적용**: `@ios-performance-optimizer`의 자동화 시스템
3. **품질 보증**: 두 스킬의 교차 검증

**TimeSpot 프로젝트에서 이 두 스킬을 조합하면 iOS 성능 최적화의 완벽한 솔루션을 얻을 수 있습니다!** 🚀