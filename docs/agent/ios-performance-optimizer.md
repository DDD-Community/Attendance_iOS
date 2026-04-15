# 🚀 iOS 자동 성능 최적화 & TCA 전문 분석 시스템 v2.3

전문적인 iOS 성능 최적화 에이전트로, **자동 개선 계획 생성**, **승인 기반 코드 수정**, **빌드 시스템 통합**, **Swift Concurrency 최적화**, **Claude vs Codex 비교 분석**, **TCA Flow & Coordinator 전문 분석** 기능이 추가되었습니다.

## ✨ 새로운 기능 (v2.1)

### 🎯 자동 개선 시스템
- **📊 종합 분석**: 7개 전문 서브에이전트 동시 실행
- **📋 자동 계획 생성**: Critical/High/Medium 우선순위별 개선 계획
- **✋ 승인 프로세스**: 각 수정사항에 대한 사용자 승인 요청
- **🔧 자동 코드 수정**: 승인된 항목만 실제 코드 자동 수정
- **🔨 빌드 시스템 통합**: Tuist/Xcode/SPM/fastlane 자동 감지 및 실행
- **📈 결과 보고**: 수정 완료 후 성능 개선 효과 리포트

### 🤖 12개 전문 서브에이전트
- **ios-performance**: 메모리 누수, CPU 최적화, 배터리 효율성
- **swiftui-auditor**: SwiftUI 성능, 렌더링 최적화  
- **tca-optimizer**: TCA Store, Effect, Reducer + **TCAFlow & TCACoordinator 전문 최적화**
- **swift-concurrency**: Task, async/await, Actor 최적화 
- **clean-architecture**: iOS 아키텍처, SOLID 원칙, Protocol-Oriented
- **apple-design-system**: HIG, SF Symbols, 접근성 가이드라인
- **tuist-optimizer**: Tuist 프로젝트 구조 및 의존성 최적화 
- **codex-comparator**: Claude vs Codex 비교 분석 및 최적 솔루션도출
- **tca-flow**: **@FlowCoordinator 매크로, TCAFlowRouter, handleRoute 패턴** 🆕
- **tca-coordinator**: **forEachRoute → TCAFlow 마이그레이션, 네비게이션 최적화** 🆕
- **swift-di-architect**: **WeaveDI, Swinject, DI 컨테이너 성능 최적화** 🆕
- **pfw-dependencies**: **Point-Free Dependencies 라이브러리, 테스트 의존성 제어** 🆕

## 🛠️ 설치 및 설정

### 1. 환경 설정
```bash
# API 키 설정
cp .env.example .env
# .env 파일에서 필수: ANTHROPIC_API_KEY 설정
# 선택사항: OPENAI_API_KEY (실제 Codex 비교용)
```

### 2. 의존성 설치
```bash
npm install
```

### 3. TypeScript 컴파일 확인
```bash
npm run typecheck
```

## 🚀 사용 방법

### 자동 최적화 시스템 실행
```bash
# 전체 자동 최적화 (분석 → 계획 → 승인 → 수정 → 빌드)
npm start

# 특정 영역 최적화
npm start "SwiftUI 성능 최적화하고 자동으로 수정해줘"
npm start "TCA 아키텍처 분석하고 개선점 자동 적용해줘"
npm start "메모리 누수 찾아서 자동으로 수정해줘"
npm start "Swift Concurrency 최적화하고 빌드까지 해줘"

# 빌드 시스템별 최적화
npm start "Tuist 프로젝트 최적화하고 빌드 성능 개선해줘"
npm start "Xcode 프로젝트 컴파일 시간 단축해줘"

# AI 비교 분석 (고급)
npm start "Claude와 Codex 비교 분석으로 최고의 최적화 방안 찾아줘"
npm start "여러 최적화 옵션 중에서 AI 비교로 최적 솔루션 선택해줘"

# TCA 전문 패턴 최적화 (신규) - TCAFlow & TCACoordinator
npm start "@FlowCoordinator 매크로 최적화하고 Swift 6 호환성 적용해줘"
npm start "TCACoordinator를 TCAFlow로 마이그레이션해줘"
npm start "handleRoute 패턴으로 자동 변환하고 성능 최적화해줘"
npm start "TCAFlowRouter 성능 개선하고 라우팅 API 최적화해줘"
npm start "GitHub TCAFlow 최신 패턴 확인하고 코드 업데이트해줘"
npm start "forEachRoute를 handleRoute로 자동 마이그레이션해줘"
npm start "routeWithDelaysIfUnsupported 제거하고 TCAFlow 패턴 적용해줘"

# WeaveDI 3.4.0 혁신 아키텍처 최적화 (신규)
npm start "@DependencyConfiguration 선언적 설정으로 90% 코드 감소 적용해줘"
npm start "@Component Needle 스타일로 컴파일 타임 자동 생성 최적화해줘"
npm start "@AutoRegister 매크로로 수명주기 자동 관리 적용해줘"
npm start "@DIActor 매크로로 Swift 6 Concurrency 자동 변환해줘"
npm start "AutoDIOptimizer로 의존성 그래프 최적화하고 Actor hop 제거해줘"
npm start "UnifiedDI와 ModuleFactoryManager 통합 아키텍처 적용해줘"
npm start "TCA @Dependency와 WeaveDI @Injected 타입 충돌 해결해줘"
npm start "@DependencyGraph로 순환 의존성 컴파일 타임 검증해줘"
npm start "Swinject/Service Locator를 WeaveDI 3.4.0으로 마이그레이션해줘"
```

### 분석만 실행 (수정 없이)
```bash
npm start "분석만 해줘 - 수정 안해도 돼"
```

## 📊 자동 최적화 프로세스

### 1단계: 종합 분석
```
🔍 Swift 프로젝트 자동 감지
├── ios-performance 서브에이전트 실행
├── tca-optimizer 서브에이전트 실행  
├── swiftui-auditor 서브에이전트 실행
└── clean-architecture 서브에이전트 실행
```

### 2단계: 자동 개선 계획 생성
```
📋 자동 개선 계획
==================

🔥 Critical Issues (즉시 수정 권장)
1. QRScannerRepresentable.swift:76 - 메모리 누수 위험
   → DispatchWorkItem 수명 관리 개선

⚡ High Priority Issues (1주 내 수정 권장)  
1. LoadingView.swift:36 - GIF 애니메이션 항상 활성화
   → 조건부 애니메이션으로 최적화

🔧 Medium Priority Issues (2주 내 수정 권장)
1. AttendanceCard.swift:88 - 불필요한 뷰 재생성
   → 스타일 캐싱으로 렌더링 최적화
```

### 3단계: 승인 프로세스
```
🔧 자동 수정 승인 요청

파일: QRScannerRepresentable.swift
문제: DispatchWorkItem 메모리 누수 위험
수정방안: 
// Before
var scanTimeoutTask: DispatchWorkItem?

// After  
private var scanTimeoutTask: DispatchWorkItem?
private let scanTimeoutQueue = DispatchQueue(label: "qr.scan.timeout")

예상효과: 메모리 사용량 15% 감소

이 수정을 자동으로 진행하시겠습니까? (y/n)
```

### 4단계: 자동 코드 수정
```
✅ 자동 수정 완료: QRScannerRepresentable.swift
✅ 자동 수정 완료: LoadingView.swift  
✅ 자동 수정 완료: AttendanceCard.swift
```

### 5단계: 완료 보고서
```
✅ 자동 개선 완료 보고서
========================

📊 수정된 파일: 3개
🚀 예상 성능 개선: 
💾 메모리 사용량: -20% 개선
⚡ CPU 성능: -15% 개선  
🔋 배터리 효율: +10% 개선

📋 수정 내역:
1. QRScannerRepresentable.swift - 메모리 누수 해결 - 15% 메모리 절약
2. LoadingView.swift - 애니메이션 최적화 - 10% CPU 절약
3. AttendanceCard.swift - 렌더링 최적화 - 25% 뷰 업데이트 감소

🎯 다음 권장사항:
- Instruments로 성능 개선 효과 측정
- 추가 최적화를 위해 다시 실행 권장
```

## 📈 성능 최적화 영역

### SwiftUI 자동 최적화
- **View 무효화 최적화**: 불필요한 재렌더링 제거
- **ForEach Identity 안정화**: 리스트 성능 향상
- **애니메이션 최적화**: GPU 부하 감소
- **Layout 최적화**: GeometryReader 사용 개선

### TCA 자동 최적화  
- **Store 구독 최적화**: ViewStore 선택적 관찰
- **Effect 관리**: 취소 시스템 및 메모리 누수 방지
- **Reducer 효율성**: 상태 업데이트 패턴 개선
- **의존성 주입**: TCA Dependencies 최적화

### 🚀 TCAFlow & TCACoordinator 전문 최적화 🆕
- **@FlowCoordinator 매크로 최적화**:
  ```swift
  // ✅ 자동 최적화 적용 후
  @FlowCoordinator(screen: "ScreenName", navigation: true)
  public struct SomeCoordinator: Sendable {  // Equatable 자동 생성, Sendable만 추가
    public init() {}
    // ❌ == 연산자 수동 구현 불필요 (매크로가 자동 처리)
  }
  ```

- **TCACoordinator → TCAFlow 자동 마이그레이션**:
  ```swift
  // Before (TCACoordinator 구식 패턴)
  .forEachRoute { screen in
    switch screen {
    case .detail: DetailView()
    }
  }
  
  // After (TCAFlow 최신 패턴) - 자동 변환
  .handleRoute { screen in
    switch screen {
    case .detail: DetailView()
    }
  }
  ```

- **TCAFlowRouter 성능 최적화**: Route 배열 관리 효율성 개선
- **라우팅 API 최적화**: `.push`, `.goBack`, `.goBackTo`, `.goBackToRoot` 성능 향상
- **GitHub 소스 코드 실시간 확인**: https://github.com/Roy-wonji/TCAFlow 최신 패턴 자동 적용
- **Swift 6 Concurrency 호환성**: Sendable 준수 자동 적용

### 🏗️ WeaveDI 3.4.0 아키텍처 전문 최적화 🆕
- **@DependencyConfiguration 선언적 설정 (현재 3.4.0)**:
  ```swift
  // ✅ WeaveDI 3.4.0 혁신 패턴 - 90% 코드 감소!
  @DependencyConfiguration
  var appDependencies {
    UserServiceImpl()
    RepositoryImpl()
    DatabaseService()
  }
  appDependencies.configure()  // SwiftUI ViewBuilder 패턴 영감
  ```

- **@Component: Needle 스타일 컴파일 타임 자동 생성**:
  ```swift
  // 컴파일 타임 자동 생성으로 10배 빠른 성능
  @Component
  struct UserComponent {
    @Provide var userService: UserService = UserService()
    @Provide var userRepository: UserRepository = UserRepository()
  }
  ```

- **@AutoRegister: 자동 등록 매크로**:
  ```swift
  // 수명 주기 자동 관리 - 컴파일 타임 등록
  @AutoRegister(lifetime: .singleton)
  class DatabaseService: DatabaseServiceProtocol { }
  
  @AutoRegister(lifetime: .transient)  
  class RequestHandler: RequestHandlerProtocol { }
  ```

- **@DIActor & @DependencyGraph: Swift 6 Concurrency**:
  ```swift
  @DIActor  // 클래스를 Actor로 자동 변환
  class ConcurrentService { }
  
  @DependencyGraph  // 순환 의존성 컴파일 타임 검증
  struct AppGraph { }
  ```

- **WeaveDI 3.4.0 혁신 특징**:
  - **AutoDIOptimizer**: 의존성 그래프 자동 분석 및 최적 주입 경로 결정
  - **Actor Hop 감지**: 불필요한 actor hop 자동 제거
  - **컴파일 시간 50% 단축**: 9개 모듈 → 3개 모듈 축소
  - **번들 크기 최적화**: 의존성 체인 최소화

- **Swift 6 Strict Concurrency 네이티브**:
  - **@Injected**: `@Injected var service: Service` (타입만으로 해결)
  - **환경별 자동 분기**: `#if DEBUG` / `#else` 자동 처리
  - **TCA 타입 충돌 완전 해결**: `@Dependency`와 `@Injected` 동시 사용

- **UnifiedDI & ModuleFactoryManager**:
  - **통합 DI 컨테이너**: WeaveDICore 엔진 기반
  - **모듈 팩토리**: Repository, UseCase 체계적 관리
  - **키패스 100% 호환**: `@Injected(\.userService)` 점진적 마이그레이션

### iOS 아키텍처 자동 개선
- **SOLID 원칙 준수**: 단일 책임, 의존성 역전 등
- **Protocol-Oriented**: Swift 프로토콜 활용 개선
- **계층 분리**: Presentation, Domain, Infrastructure
- **의존성 방향**: 올바른 아키텍처 경계 설정

### 메모리 관리 자동 수정
- **강한 참조 순환 해결**: [weak self] 자동 추가
- **Timer 정리**: 메모리 누수 방지
- **Notification 관리**: 옵저버 자동 해제
- **이미지 캐싱**: 메모리 효율성 개선

### Swift Concurrency 자동 최적화 🆕
- **Task 생명주기 관리**: 적절한 Task 취소 및 메모리 누수 방지
- **MainActor 최적화**: 불필요한 메인 스레드 사용 제거
- **async/await 패턴**: 비동기 함수 호출 효율성 개선
- **Actor 격리**: 데이터 레이스 방지 및 성능 향상

### 빌드 시스템 통합 🆕
- **Tuist 프로젝트**: tuist generate && tuist build 자동 실행
- **Xcode 프로젝트**: xcodebuild 스킴 자동 감지 및 빌드
- **Swift Package Manager**: swift build 패키지 빌드
- **fastlane**: 커스텀 빌드 lane 자동 실행

---

**🚀 이제 iOS 성능 최적화가 완전 자동화되었습니다!**
**📊 분석 → 📋 계획 → ✋ 승인 → 🔧 수정 → 📈 보고**

**🎯 TCAFlow & TCACoordinator 마이그레이션도 완전 자동화!**
**🔄 감지 → 📋 GitHub 확인 → 🔧 자동 변환 → ⚡ 성능 최적화**

**🏗️ Swift DI 아키텍처 최적화도 완전 자동화!**
**📊 DI 분석 → 🔄 WeaveDI 마이그레이션 → ⚡ Type-safe 최적화 → 🧪 테스트 자동화**