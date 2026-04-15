# DDDAttendance iOS Architecture Guide

## 📱 프로젝트 개요

- **프로젝트명**: DDDAttendance (출석 관리 시스템)
- **스택**: Swift 6, SwiftUI, TCA 1.25, Tuist 4
- **아키텍처**: TCA + Clean Architecture 멀티모듈  
- **배포 타겟**: iOS 26.0, iPhone 전용
- **네비게이션**: TCAFlow @FlowCoordinator
- **의존성 주입**: WeaveDI

## 🏗️ 아키텍처 및 모듈 구조

### Clean Architecture 계층

```
Projects/
├── App/                  # 앱 타겟 (진입점, DI 조립)
│   ├── Di/              # WeaveDI 의존성 등록
│   ├── Reducer/         # AppReducer (루트 상태 관리)
│   └── Application/     # App Entry Point
├── Presentation/         # 화면 + ViewModel (TCA Feature)
│   ├── Auth/            # 인증 플로우 (Login, OnBoarding)
│   ├── Attendance/      # 출석 관리 플로우
│   ├── Schedule/        # 스케줄 관리 플로우
│   ├── Profile/         # 프로필 플로우
│   └── Common/          # 공통 프레젠테이션 컴포넌트
├── Domain/
│   ├── Entity/           # 도메인 엔티티 + Protocol
│   ├── UseCase/          # 비즈니스 로직 구현
│   └── DomainInterface/  # Repository 인터페이스 및 Mock 구현체
├── Data/
│   ├── Model/            # DTO, API Response → Entity 변환
│   ├── Repository/       # Repository 구현체
│   ├── API/              # REST API Endpoint
│   └── Service/          # 데이터 처리 서비스
├── Network/
│   ├── Networking/       # HTTP 클라이언트 설정
│   ├── Foundations/      # 네트워크 기반 유틸리티 (Token, Header)
│   └── ThirdPartys/      # AsyncMoya, WeaveDI 등
└── Shared/
    ├── DesignSystem/     # 공통 UI 컴포넌트, 폰트, 색상
    ├── Shared/           # 공통 공유 모듈
    └── Utill/            # 날짜, 문자열, 로깅 유틸리티
```

**의존성 방향**: `Presentation → Domain ← Data`, `Network`는 `Data`에서만 참조

### 주요 의존성

```swift
// Core Architecture
ComposableArchitecture: 1.25.5+   // TCA (자동 최신 버전)
TCAFlow: 1.1.1+                    // 네비게이션 관리 (자동 최신 버전)
WeaveDI: 3.4.1                     // 의존성 주입

// Networking  
AsyncMoya: 1.1.8                   // 비동기 네트워크
ReactiveSwift: 6.7.0               // 리액티브 프로그래밍

// Authentication
AppAuth-iOS: 2.0.0                 // OAuth 2.0
GoogleSignIn-iOS: 9.1.0            // Google 소셜 로그인

// Analytics & Monitoring
Firebase: 12.12.0                  // 분석, 크래시리틱스
Mixpanel: 5.1.3                    // 사용자 행동 분석
```

## 📚 세부 가이드 문서

프로젝트의 상세한 가이드라인은 다음 agent 폴더의 문서들을 참고하세요:

### 🔄 [TCA 패턴 가이드](./agent/tca-patterns.md)
- TCA 기본 구조 및 규칙
- Extension 패턴 활용법
- Action 처리 메서드 분리
- State Computed Properties
- Coordinator Extension 패턴

### 🎨 [SwiftUI 스타일 가이드](./agent/swiftui-patterns.md)
- SwiftUI 코드 구조화
- View Extension 패턴
- Computed Properties + @ViewBuilder 조합
- 조건부 렌더링 및 Skeleton 패턴

### 📏 [Swift 코딩 규칙](./agent/swift-coding-rules.md)
- Swift 스타일 가이드
- 에러 처리 패턴
- TCA 에러 처리 규칙
- 테스트 패턴

### 🚀 [iOS 성능 최적화](./agent/ios-performance-optimization.md)
- 성능 최적화 통합 시스템
- 서브에이전트 호출 규칙
- TCA/SwiftUI 성능 문제 해결
- 빌드 오류 해결 프로세스

### 🎯 [Git 워크플로우](./agent/git-workflow.md)
- 브랜치 전략
- 커밋 메시지 컨벤션
- Pull Request 규칙
- 코드 리뷰 가이드라인

### 🔧 [개발 환경 설정](./agent/development-environment.md)
- Make 명령어
- Xcode 빌드 설정
- Tuist 사용 규칙
- 테스트 패턴

## 🔄 DI (Dependency Injection) with WeaveDI

### AppDIManager 구조

```swift
@MainActor
public final class AppDIManager {
    public static let shared = AppDIManager()
    
    public func registerDefaultDependencies() async {
        WeaveDI.builder
            // 인프라 계층
            .register { KeychainManager() as KeychainManagingInterface }
            .register { 
                let keychainManager = UnifiedDI.resolve(KeychainManagingInterface.self) ?? KeychainManager()
                return KeychainTokenProvider(keychainManager: keychainManager) as TokenProviding 
            }
            
            // Repository 계층 (Data → Domain Interface)
            .register { AuthRepositoryImpl() as AuthInterface }
            .register { ProfileRepositoryImpl() as ProfileInterface }
            .register { AttendanceRepositoryImpl() as AttendanceInterface }
            
            // OAuth Provider 계층
            .register { GoogleOAuthRepositoryImpl() as GoogleOAuthInterface }
            .register { AppleLoginRepositoryImpl() as AppleAuthRequestInterface }
            
            .configure()
    }
}
```

### DI 사용 패턴

```swift
// Repository에서 의존성 주입 (TCA Dependencies 활용)
public final class AuthRepositoryImpl: AuthInterface {
  @Dependency(\.keychainManager) private var keychainManager
  private let provider: MoyaProvider<AuthService>
  private let authProvider: MoyaProvider<AuthService>
  
  public init(
    provider: MoyaProvider<AuthService> = MoyaProvider<AuthService>.default,
    authProvider: MoyaProvider<AuthService> = MoyaProvider<AuthService>.authorized
  ) {
    self.provider = provider
    self.authProvider = authProvider
  }
  
  public func login(request: LoginRequest) async throws -> LoginResponse {
    // 구현
  }
}

// TCA Feature에서 의존성 사용
@Reducer
public struct LoginFeature {
  @Dependency(\.authRepository) var authRepository
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .loginButtonTapped:
        return .run { [state] send in
          let response = try await authRepository.login(request: state.loginRequest)
          await send(.loginResponse(.success(response)))
        }
      }
    }
  }
}
```

### 의존성 등록 규칙

1. **Interface 기반 등록**: 구체 타입이 아닌 Protocol로 등록
2. **계층별 분리**: Repository, UseCase, Provider별로 주석으로 그룹화  
3. **생성자 주입**: `@Injected` 프로퍼티 래퍼 활용
4. **싱글톤 관리**: `AppDIManager.shared`로 전역 관리

## 🧭 TCAFlow 네비게이션 패턴

### @FlowCoordinator 구조

```swift
@FlowCoordinator(screen: "ScreenName", navigation: true)
public struct FeatureCoordinator {
    
    @ObservableState
    public struct State: Equatable {
        var routes: [Route<FeatureScreen.State>]
        
        public init() {
            // 초기 화면 설정
            self.routes = [.root(.login(.init()), embedInNavigationView: true)]
        }
    }
    
    @CasePathable
    public enum Action {
        case router(IndexedRouterActionOf<FeatureScreen>)
        case view(View)
        case async(AsyncAction) 
        case inner(InnerAction)
        case navigation(NavigationAction)
    }
    
    // 라우팅 처리
    func handleRoute(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .router(let routeAction):
            return routerAction(state: &state, action: routeAction)
        // ...
        }
    }
}

// 화면 정의
@Reducer
public enum FeatureScreen {
    case screenA(ScreenAFeature)
    case screenB(ScreenBFeature)
    case screenC(ScreenCFeature)
}
```

### 네비게이션 동작

```swift
// Push
state.routes.push(.screenA(.init()))

// Present (Modal)
state.routes.present(.screenB(.init()))

// Go Back
state.routes.goBack()

// Go Back to Root
state.routes.goBackToRoot()

// Replace Current
state.routes.replaceCurrent(.screenC(.init()))

// 지연된 라우팅 (애니메이션 충돌 방지)
return routeWithDelaysIfUnsupported(state.routes, action: \.router) {
    $0.push(.nextScreen(.init()))
}
```

### 화면 간 통신

```swift
// 자식 → 부모 (Delegate Action)
case .routeAction(id: _, action: .login(.delegate(.presentMain))):
    return .send(.navigation(.presentMain))

// 부모 → 자식 (State 업데이트)  
case .routeAction(id: _, action: .profile(.inner(.updateUserInfo(let info)))):
    // 자식 Feature의 상태를 부모에서 업데이트
    return .none
```

## 🚨 팝업 & 모달 시스템

프로젝트에서는 **3가지 방식**의 팝업/모달 시스템을 제공합니다.

### 1. CustomAlert (TCA 기반 커스텀 알림)

#### State 정의

```swift
@Reducer
public struct FeatureName {
  @ObservableState
  public struct State: Equatable {
    // CustomAlert 상태
    @Presents public var customAlert: CustomAlertState<CustomAlertAction>?
    var customAlertMode: CustomAlertMode? = nil
  }
  
  public enum Action {
    case view(View)
    case inner(InnerAction)
    case customAlert(PresentationAction<CustomAlertAction>)
  }
  
  // CustomAlert 모드 정의
  public enum CustomAlertMode: Equatable {
    case loginRequired
    case locationPermissionRequired
    case withdrawAccount
  }
}
```

### 2. Toast 시스템 (전역 메시지)

#### 기본 사용법

```swift
// TCA Reducer에서 Toast 표시
case .loginSuccess:
  ToastManager.shared.showSuccess("로그인에 성공했습니다!")
  return .none
  
case .loginFailure(let error):
  ToastManager.shared.showError("인증에 실패했어요. 다시 시도해주세요.")
  return .none
```

### 3. CustomModal (드래그 지원 모달)

```swift
.presentDSModal(
  item: $store.scope(state: \.trainStationSheet, action: \.trainStationSheet),
  height: .fraction(0.8),  // 화면의 80% 높이
  showDragIndicator: true
) { store in
  TrainStationView(store: store)
}
```

## 📊 지원 스킬 목록

### 성능 최적화 스킬
- `@ios-performance-optimizer` - PFW 철학 통합 자동화 시스템 (v4.0)
- `@ios-performance-pfw` - Point-Free Workshop 전문
- `@swiftui-uikit-interop` - SwiftUI ↔ UIKit 상호 운용성 전문
- `@swift-concurrency` - Swift 6 Concurrency 및 async/await 전문

### 자동 호출 키워드
다음 키워드 언급 시 **자동으로 성능 최적화 스킬 호출**:
- `ifCaseLet`, `TCA`, `Effect`, `메모리 누수`, `성능`, `최적화`
- `SwiftUI`, `렌더링`, `빌드 시간`, `TCAFlow`, `WeaveDI`  
- `Cannot infer`, `Extensions must not`, `Type annotation missing`
- `빌드 오류`, `컴파일 에러`, `SourceKit error`

---

이 문서는 DDDAttendance iOS 프로젝트의 **아키텍처 가이드라인**입니다. 
새로운 기능 개발이나 코드 리뷰 시 이 가이드와 세부 문서들을 참고하여 일관성 있는 코드를 작성해주세요.