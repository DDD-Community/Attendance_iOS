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

## 🔄 TCA (The Composable Architecture) 패턴

### 기본 구조

```swift
@Reducer
public struct FeatureName {
    @ObservableState
    public struct State: Equatable {
        // 상태 정의
    }
    
    @CasePathable  
    public enum Action {
        case view(View)           // 뷰 액션
        case async(AsyncAction)   // 비동기 액션  
        case inner(InnerAction)   // 내부 로직 액션
        case delegate(Delegate)   // 부모에게 전달할 액션
    }
    
    // Action 세분화
    public enum View { /* 사용자 인터랙션 */ }
    public enum AsyncAction { /* 비동기 처리 */ }
    public enum InnerAction { /* 내부 로직 */ }
    public enum Delegate { /* 부모 통신 */ }
}
```

### TCA 규칙

- **`@Reducer` 매크로** + **`@ObservableState`** 필수 사용
- **Action 네이밍**: 이벤트 기반 (`incrementButtonTapped`, `userInfoReceived`)
- **Effect 처리**: 
  - 부작용 없으면 `.none`
  - 비동기 작업은 `.run { send in ... }`
  - CPU 집약 작업은 Effect 내에서 처리
- **Store 선언**: `StoreOf<Feature>` 타입 활용
- **액션 간 로직 공유 지양** (헬퍼 메서드로 분리)
- **Extension 활용**: Action 처리 메서드와 State computed property 분리
- **테스트**: `TestStore` 패턴으로 상태 변화 검증

### TCA Extension 패턴 (실제 프로젝트 활용법)

#### 1. Action 처리 메서드 분리

```swift
@Reducer
public struct HomeFeature {
  @ObservableState
  public struct State: Equatable {
    // 상태 정의
  }
  
  public enum Action {
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(Delegate)
  }
  
  // 메인 body에서는 액션 라우팅만
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)
        
      case .delegate:
        return .none
      }
    }
  }
}

// MARK: - Action Handlers (Extension으로 분리)
extension HomeFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .exploreButtonTapped:
      guard state.isExploreNearbyEnabled else { return .none }
      state.isLoading = true
      return .send(.async(.fetchNearbyPlaces))
      
    case .stationSelectionTapped:
      state.trainStationSheet = TrainStationFeature.State()
      return .none
    }
  }
  
  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchNearbyPlaces:
      return .run { [location = state.selectedStation] send in
        let places = try await placeRepository.fetchNearbyPlaces(location: location)
        await send(.inner(.nearbyPlacesResponse(.success(places))))
      }
      
    case .loginRequired:
      state.customAlert = CustomAlertState.loginRequired()
      return .none
    }
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .nearbyPlacesResponse(let result):
      state.isLoading = false
      switch result {
      case .success(let places):
        state.nearbyPlaces = places
        return .send(.delegate(.placesLoaded(places)))
      case .failure(let error):
        state.errorMessage = error.localizedDescription
        return .none
      }
    }
  }
}
```

#### 2. State Extension (Computed Properties)

```swift
// State의 비즈니스 로직은 extension으로 분리
extension HomeFeature.State {
  // 최대 출발 시간 계산 (다음날 23:59까지)
  var maxDepartureTime: Date {
    let calendar = Calendar.current
    let now = Date()
    let nextDay = calendar.date(byAdding: .day, value: 1, to: now) ?? now
    
    var components = calendar.dateComponents([.year, .month, .day], from: nextDay)
    components.hour = 23
    components.minute = 59
    components.second = 59
    
    return calendar.date(from: components) ?? nextDay
  }
  
  // 남은 시간 (분 단위)
  var remainingTotalMinutes: Int {
    (remainingTime.hour ?? 0) * 60 + (remainingTime.minute ?? 0)
  }
  
  // 역 선택 완료 여부
  var isStationReady: Bool {
    hasSelectedStation && selectedStation != nil
  }
  
  // 주변 탐색 가능 여부
  var isExploreNearbyEnabled: Bool {
    isStationReady && isDepartureTimeSet && remainingTotalMinutes > 20
  }
  
  // 경로 탐색 가능 여부 
  var isRouteSearchEnabled: Bool {
    hasSelectedStation && selectedPlace != nil
  }
  
  // UI 상태 계산
  var shouldShowTimeWarning: Bool {
    isDepartureTimeSet && remainingTotalMinutes <= 30
  }
  
  var progressPercentage: Double {
    guard remainingTotalMinutes > 0 else { return 0 }
    let totalTime = 120 // 2시간 기준
    return min(Double(remainingTotalMinutes) / Double(totalTime), 1.0)
  }
}
```

#### 3. Coordinator Extension 패턴

```swift
extension AuthCoordinator {
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<AuthScreen>
  ) -> Effect<Action> {
    switch action {
    case .routeAction(id: _, action: .login(.delegate(.presentOnBoarding))):
      return .send(.inner(.pushOnBoarding))
      
    case .routeAction(id: _, action: .login(.delegate(.presentMain))):
      return .send(.navigation(.presentMain))
      
    case .routeAction(id: _, action: .onBoarding(.navigation(.onBoardingCompleted))):
      return .send(.navigation(.presentMain))
      
    default:
      return .none
    }
  }
  
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .backAction:
      state.routes.goBack()
      return .none
      
    case .backToRootAction:
      state.routes.goBackToRoot()
      return .none
    }
  }
  
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentMain:
      // 부모 Coordinator로 전달
      return .none
    }
  }
}
```

#### Extension 활용 규칙

1. **Action 핸들러**: 각 Action 타입별로 `handle{ActionType}Action` 메서드로 분리
2. **State 로직**: 복잡한 계산은 computed property로 extension에 분리
3. **네이밍**: `handle` + `{ActionType}` + `Action` 패턴 준수
4. **접근 제어**: 핸들러 메서드는 `private` 사용
5. **파일 구성**: extension은 `// MARK: -` 주석으로 구분
6. **의존성**: extension 내에서도 `@Dependency` 직접 사용 가능

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

#### Reducer 구성

```swift
public var body: some ReducerOf<Self> {
  Reduce { state, action in
    // 액션 처리
  }
  .ifLet(\.$customAlert, action: \.customAlert) {
    CustomConfirmAlert()
  }
}

// CustomAlert 핸들러 (Extension)
extension FeatureName {
  private func handleCustomAlertAction(
    state: inout State,
    action: PresentationAction<CustomAlertAction>
  ) -> Effect<Action> {
    switch action {
    case .presented(.confirmTapped):
      switch state.customAlertMode {
      case .loginRequired:
        state.customAlert = nil
        state.customAlertMode = nil
        return .send(.delegate(.presentAuth))
        
      case .withdrawAccount:
        state.customAlert = nil
        return .send(.inner(.performWithdraw))
        
      case .none:
        state.customAlert = nil
        return .none
      }
      
    case .presented(.cancelTapped), .dismiss:
      state.customAlert = nil
      state.customAlertMode = nil
      return .none
      
    case .presented(.policyTapped):
      return .send(.inner(.presentPrivacyPolicy))
    }
  }
}
```

#### View에서 사용

```swift
struct FeatureView: View {
  @Bindable var store: StoreOf<FeatureName>
  
  var body: some View {
    VStack {
      // 메인 콘텐츠
      Button("로그인 필요 액션") {
        store.send(.view(.loginRequiredAction))
      }
    }
    .customAlert($store.scope(state: \.customAlert, action: \.customAlert))
  }
}
```

#### 미리 정의된 Alert 사용

```swift
// Action 처리에서 Alert 표시
case .loginRequiredAction:
  state.customAlert = .alert(
    title: "로그인이 필요합니다",
    message: "이 기능을 사용하려면 로그인해 주세요.",
    confirmTitle: "로그인",
    cancelTitle: "취소"
  )
  state.customAlertMode = .loginRequired
  return .none

// 미리 정의된 Alert들
state.customAlert = .withdrawAccount()  // 회원탈퇴 확인
state.customAlert = .logout()           // 로그아웃 확인
state.customAlert = .privacyPolicyConsent()  // 개인정보 동의
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
  
case .networkError:
  ToastManager.shared.showWarning("네트워크 연결을 확인해주세요.")
  return .none

case .insufficientWaitTime:
  ToastManager.shared.showWarning("대기 시간이 부족합니다 (최소 20분 필요)")
  return .none
```

#### Toast 타입들

```swift
// 성공 메시지 (녹색)
ToastManager.shared.showSuccess("작업이 완료되었습니다!")

// 에러 메시지 (빨간색)  
ToastManager.shared.showError("오류가 발생했습니다.")

// 경고 메시지 (주황색)
ToastManager.shared.showWarning("주의가 필요합니다.")

// 정보 메시지 (파란색)
ToastManager.shared.showInfo("새로운 업데이트가 있습니다.")

// 로딩 메시지 (자동으로 사라지지 않음)
ToastManager.shared.showLoading("데이터를 불러오는 중...")

// 수동으로 숨기기
ToastManager.shared.hideToast()
```

#### App에서 Toast 설정

```swift
struct App: View {
  var body: some View {
    ContentView()
      .overlay(
        ToastView()  // 앱 최상단에 Toast 오버레이
          .zIndex(999)
      )
  }
}
```

### 3. CustomModal (드래그 지원 모달)

#### State 정의

```swift
@Reducer
public struct FeatureName {
  @ObservableState
  public struct State: Equatable {
    @Presents public var trainStationSheet: TrainStationFeature.State?
    @Presents public var profileEditSheet: ProfileEditFeature.State?
  }
  
  public enum Action {
    case trainStationSheet(PresentationAction<TrainStationFeature.Action>)
    case profileEditSheet(PresentationAction<ProfileEditFeature.Action>)
  }
}
```

#### View에서 Modal 사용

```swift
struct FeatureView: View {
  @Bindable var store: StoreOf<FeatureName>
  
  var body: some View {
    VStack {
      Button("역 선택") {
        store.send(.view(.presentTrainStationSheet))
      }
    }
    .presentDSModal(
      item: $store.scope(state: \.trainStationSheet, action: \.trainStationSheet),
      height: .fraction(0.8),  // 화면의 80% 높이
      showDragIndicator: true
    ) { store in
      TrainStationView(store: store)
    }
    .presentDSModal(
      item: $store.scope(state: \.profileEditSheet, action: \.profileEditSheet),
      height: .fixed(600),  // 고정 높이
      showDragIndicator: false
    ) { store in
      ProfileEditView(store: store)
    }
  }
}
```

#### Modal 높이 옵션

```swift
// 화면 비율 기준
.presentDSModal(height: .fraction(0.7))  // 70%

// 고정 높이
.presentDSModal(height: .fixed(500))     // 500pt

// 내용에 맞춤
.presentDSModal(height: .auto)           // 자동 조정
```

#### Modal 내에서 닫기

```swift
struct ModalContentView: View {
  @Environment(\.modalDismiss) var dismiss
  
  var body: some View {
    VStack {
      Button("닫기") {
        dismiss()  // Environment를 통한 모달 닫기
      }
    }
  }
}
```

### 4. 팝업/모달 사용 가이드라인

#### 언제 어떤 것을 사용할까?

```swift
// ✅ CustomAlert - 사용자 확인이 필요한 중요한 액션
state.customAlert = .withdrawAccount()  // 회원탈퇴
state.customAlert = .logout()          // 로그아웃

// ✅ Toast - 간단한 피드백 메시지 (자동으로 사라짐)
ToastManager.shared.showSuccess("저장되었습니다")
ToastManager.shared.showError("네트워크 오류")

// ✅ CustomModal - 복잡한 UI가 필요한 경우
.presentDSModal(item: $store.trainStationSheet) { store in
  TrainStationView(store: store)  // 전체 화면이 필요한 기능
}
```

#### TCA Presentation 패턴 규칙

1. **@Presents**: 모든 팝업/모달 상태는 `@Presents` 사용
2. **PresentationAction**: 액션에 `PresentationAction<ChildAction>` 포함
3. **ifLet**: Reducer에서 `.ifLet` 연산자로 자식 기능 연결
4. **State 초기화**: 팝업 표시 시 자식 State를 새로 생성
5. **nil 할당**: 팝업 닫기 시 상태를 `nil`로 설정

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

## 💉 DI (Dependency Injection) with WeaveDI

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
            .register { DirectionRepositoryImpl() as DirectionInterface }
            
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

## 🎨 SwiftUI 코드 스타일

### 뷰 구조화

```swift
// ✅ 올바른 패턴
struct ProfileView: View {
    @Bindable var store: StoreOf<ProfileFeature>
    
    var body: some View {
        VStack {
            profileHeader
            profileContent  
            actionButtons
        }
        .navigationTitle("프로필")
    }
    
    // SubView는 분리된 struct로
    private var profileHeader: some View {
        ProfileHeaderView(user: store.user)
    }
    
    private var profileContent: some View {
        VStack {
            // 내용
        }
    }
}

// SubView는 별도 struct
struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        // UI 구현
    }
}
```

### 네이밍 규칙

- **View suffix 생략**: `LoginView` → `Login` 
- **Action 네이밍**: 이벤트 기반 `loginButtonTapped`, `textFieldChanged`
- **State 프로퍼티**: 명확한 의미 `isLoading`, `errorMessage`, `user`

### 레이아웃 패턴

```swift
// ✅ frame 활용한 공간 할당
VStack {
  header
  Spacer()
    .frame(maxHeight: .infinity)  // Spacer() 대신
  footer
}

// ✅ Binding을 통한 상태 전달
TextField("이메일", text: $store.email.sending(\.emailChanged))
  .textFieldStyle(.roundedBorder)
```

### SwiftUI View Extension 패턴 (실제 프로젝트 활용법)

#### 1. View 컴포넌트 분리

```swift
struct HomeView: View {
  @Bindable var store: StoreOf<HomeFeature>
  
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .topLeading) {
        logoContentView(geometry: geometry)
        mainContentView()
      }
    }
  }
}

// MARK: - View Components (Extension으로 분리)
extension HomeView {
  @ViewBuilder
  fileprivate func logoContentView(geometry: GeometryProxy) -> some View {
    ZStack(alignment: .top) {
      Image(asset: .homeLogo)
        .resizable()
        .scaledToFill()
        .frame(width: geometry.size.width, height: Layout.Hero.height)
        .scaleEffect(1.06, anchor: .top)
        .ignoresSafeArea(edges: .top)
      
      VStack {
        navigationBar()
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      
      VStack(spacing: 8) {
        selectStationView()
        selectTrainTimeView()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      .padding(.bottom, 28)
    }
  }
  
  @ViewBuilder
  private func selectStationView() -> some View {
    Button {
      store.send(.view(.stationSelectionTapped))
    } label: {
      HStack {
        Text("출발역 선택")
          .pretendardCustomFont(textStyle: .body2)
          .foregroundStyle(.gray600)
        
        Spacer()
        
        if let station = store.selectedStation {
          Text(station.name)
            .pretendardCustomFont(textStyle: .body1)
            .foregroundStyle(.staticBlack)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(.staticWhite)
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
  
  @ViewBuilder
  private func selectTrainTimeView() -> some View {
    VStack(spacing: 12) {
      timePickerView()
      
      if store.hasRemainingTimeResult {
        remainingTimeDisplayView()
      }
    }
  }
}
```

#### 2. Computed Properties + @ViewBuilder 조합

```swift
struct ProfileView: View {
  @Bindable var store: StoreOf<ProfileFeature>
  
  var body: some View {
    ScrollView {
      profileInfoCardView()
      travelHistorySection()
    }
  }
}

extension ProfileView {
  // Computed Property로 데이터 가공
  private var travelHistoryItems: [HistoryItemEntity] {
    store.historyEntity?.items ?? []
  }
  
  private var hasHistoryData: Bool {
    !travelHistoryItems.isEmpty
  }
  
  // @ViewBuilder로 UI 컴포넌트 분리
  @ViewBuilder
  private func profileInfoCardView() -> some View {
    VStack(alignment: .leading) {
      VStack {
        Spacer()
          .frame(height: 16)
        
        HStack {
          Text("\(store.profileEntity?.nickname ?? "사용자")님")
            .pretendardCustomFont(textStyle: .heading1)
            .foregroundStyle(.staticWhite)
          
          Spacer()
        }
        .padding(.horizontal, 8)
        
        providerInfoView()
      }
    }
    .padding(.horizontal, 16)
    .background(.primaryBlue500)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
  
  @ViewBuilder
  private func providerInfoView() -> some View {
    HStack {
      switch store.profileEntity?.provider {
      case .apple:
        Image(systemName: store.profileEntity?.provider.image ?? "")
          .resizable()
          .scaledToFit()
          .frame(width: 16, height: 16)
          .foregroundStyle(.staticWhite)
        
      case .google:
        AsyncImageView(
          url: store.profileEntity?.profileImageUrl,
          placeholder: Image(systemName: "person.circle")
        )
        .frame(width: 20, height: 20)
        .clipShape(Circle())
      }
      
      Text(store.profileEntity?.email ?? "")
        .pretendardCustomFont(textStyle: .caption1)
        .foregroundStyle(.staticWhite.opacity(0.8))
      
      Spacer()
    }
    .padding(.horizontal, 8)
  }
}
```

#### 3. 조건부 렌더링 + Skeleton 패턴

```swift
extension ExploreDetailView {
  @ViewBuilder
  private func contentView() -> some View {
    if store.isLoading {
      ExploreDetailSkeletonView()
    } else if let place = store.placeDetail {
      loadedContentView(place: place)
    } else {
      errorContentView()
    }
  }
  
  @ViewBuilder
  private func loadedContentView(place: PlaceDetailEntity) -> some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        placeImageSection(place: place)
        placeInfoSection(place: place)
        routeActionSection(place: place)
      }
    }
  }
  
  @ViewBuilder
  private func errorContentView() -> some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.largeTitle)
        .foregroundStyle(.gray400)
      
      Text("장소 정보를 불러올 수 없습니다")
        .pretendardCustomFont(textStyle: .body1)
        .foregroundStyle(.gray600)
      
      Button("다시 시도") {
        store.send(.view(.retryButtonTapped))
      }
      .buttonStyle(.borderedProminent)
    }
  }
}
```

#### View Extension 활용 규칙

1. **@ViewBuilder**: 모든 View 분리 메서드에 필수 사용
2. **접근 제어**: `private` 또는 `fileprivate` 사용
3. **네이밍**: 동작을 명확히 표현 (`selectStationView`, `profileInfoCardView`)
4. **계층 구조**: 큰 덩어리부터 작은 컴포넌트 순으로 분리
5. **Computed Properties**: 데이터 가공 로직은 computed property로 분리
6. **조건부 렌더링**: `@ViewBuilder`로 if/else 분기 처리
7. **파일 구성**: `// MARK: -` 주석으로 섹션 구분

## 📏 일반 코딩 규칙

### Swift 스타일

```swift
// ✅ Guard early return
guard let user = currentUser else { 
  return 
}

// ✅ Final class 기본
public final class ServiceManager {
  private let networking: NetworkingInterface
  
  public init(networking: NetworkingInterface) {
    self.networking = networking
  }
}

// ✅ Private 우선, 필요시에만 public/internal
private func validateInput() -> Bool {
  // 검증 로직
}

// ❌ Force unwrap 금지
let result = optionalValue!  // 절대 사용 금지

// ✅ Safe unwrapping
guard let result = optionalValue else { return }
```

### 에러 처리

#### Domain Error 구조

```swift
// 프로젝트의 Domain Error 타입들
Projects/Domain/Entity/Sources/Error/
├── AuthError.swift          # 인증 관련 에러
├── SignUpError.swift        # 회원가입 관련 에러
├── ProfileError.swift       # 프로필 관련 에러
├── PlaceError.swift         # 장소 검색 관련 에러
├── DirectionError.swift     # 경로 안내 관련 에러
├── StationError.swift       # 역 정보 및 즐겨찾기 관련 에러
└── HistoryError.swift       # 여행 기록 및 여정 관리 관련 에러

// AppUpdate 관련 에러는 별도 위치
Projects/Domain/Entity/Sources/AppUpdate/AppUpdateError.swift
```

#### 표준 에러 구조

```swift
public enum FeatureError: Error, LocalizedError, Equatable {
  // 네트워크 관련
  case networkError(String)
  case serverError(String)
  
  // 비즈니스 로직 관련  
  case invalidInput(String)
  case dataNotFound
  
  // 일반적인 에러
  case unknownError(String)
  case userCancelled
  
  public var errorDescription: String? {
    switch self {
    case .networkError(let message):
      return "네트워크 오류: \(message)"
    case .serverError(let message):
      return "서버 오류: \(message)"
    case .invalidInput(let field):
      return "잘못된 입력: \(field)"
    case .dataNotFound:
      return "데이터를 찾을 수 없습니다"
    case .unknownError(let message):
      return "알 수 없는 오류: \(message)"
    case .userCancelled:
      return "사용자가 취소했습니다"
    }
  }
}

// 에러 변환 메서드 필수
public extension FeatureError {
  static func from(_ error: Error) -> FeatureError {
    if let featureError = error as? FeatureError {
      return featureError
    }
    return .unknownError(error.localizedDescription)
  }
  
  var isRetryable: Bool {
    switch self {
    case .networkError, .serverError:
      return true
    default:
      return false
    }
  }
}
```

#### TCA에서 에러 처리 패턴

```swift
// 1. Action 정의 (실제 프로젝트 패턴)
public enum InnerAction {
  case signUpResponse(Result<LoginEntity, SignUpError>)
  case authResponse(Result<LoginEntity, AuthError>)
}

// 2. Effect에서 Result 래퍼 활용
return .run { [userSession = state.userSession] send in
  let signupResult = await Result {
    try await signUpUseCase.registerUser(userSession: userSession)
  }
  .mapError(SignUpError.from)  // 에러 타입 변환
  
  await send(.inner(.signUpResponse(signupResult)))
}

// 3. 결과 처리 및 UI 상태 업데이트
case .signUpResponse(let result):
  switch result {
  case .success(let loginEntity):
    state.loginEntity = loginEntity
    state.isLoading = false
    return .send(.navigation(.completed))
    
  case .failure(let error):
    state.isLoading = false
    state.errorMessage = error.localizedDescription
    
    // 재시도 가능한 에러인 경우 액션 추가
    if error.isRetryable {
      state.canRetry = true
    }
    
    return .none
  }
```

#### 에러 처리 규칙

1. **에러 타입 정의**: 기능별로 Domain/Entity/Sources/Error/에 위치
2. **`LocalizedError` 구현**: 사용자에게 보여줄 메시지 제공
3. **`from(_:)` 메서드**: 모든 에러를 해당 Feature 에러로 변환
4. **상태 기반 분류**: `isRetryable`, `isNetworkError` 등으로 UI 로직 분리
5. **TCA Result 패턴**: `.mapError(FeatureError.from)` 필수 사용
```

## 🎯 Git 규칙

### 브랜치 전략

- **`main`**: 배포용 브랜치
- **`develop`**: 통합 개발 브랜치  
- **`feature/#{issue-number}`**: 기능 개발 브랜치

### 커밋 메시지 컨벤션

```
[{Header}]: {Message}

Header 종류:
- FEAT: 새 기능 추가
- REFACTOR: 코드 리팩토링 (기능 변경 없음)
- ADD: 파일, 의존성 추가
- FIX: 버그 수정
- HOTFIX: 긴급 버그 수정
- DOCS: 문서 수정
- TEST: 테스트 코드 작성/수정
- CHORE: 기타 작업 (빌드, 설정 등)

예시:
[FEAT]: 로그인 화면 UI 구현
[REFACTOR]: AuthRepository DI 패턴 적용
[FIX]: 토큰 만료 시 자동 갱신 로직 수정
```

### Git 규칙

- **메시지**: 한국어 사용, 한 줄, 최대 50자
- **특수기호**: 마침표, 특수기호 사용 금지
- **PR**: `feature/#{issue}` → `develop` 머지
- **Body**: 필요시 작성, 무엇을 왜 변경했는지 기술

### Git 작업 플로우

#### 1. 커밋 후 푸시
```bash
# 변경사항 스테이징
git add .

# 커밋 (한국어 메시지)
git commit -m "[FEAT]: 기능 설명"

# 푸시
git push origin feature/브랜치명
```

#### 2. 푸시 규칙
- **브랜치 푸시**: 작업 완료 후 즉시 원격 브랜치에 푸시
- **Force Push 금지**: `git push --force` 절대 사용 금지 (협업 시 충돌 방지)  
- **푸시 전 확인**: `git status`로 staged 파일 확인 후 푸시
- **브랜치명 확인**: `git branch`로 현재 브랜치 확인 후 푸시
- **메인 브랜치**: `develop` 브랜치에 직접 푸시 금지, PR 통해서만 머지

### 📋 Pull Request 규칙

#### PR 크기 제한
- **파일 변경**: **30개 내외**로 제한 (최대 35개)
- **대형 PR 분할**: 기능별로 여러 PR로 나누어 리뷰 효율성 확보
- **단일 책임**: 하나의 PR은 하나의 기능/버그픽스에 집중

#### PR 분할 전략

```bash
# ❌ 잘못된 예시 (너무 큰 PR)
feature/user-management
├── 회원가입 화면 (15개 파일)
├── 프로필 편집 (12개 파일)
├── 회원탈퇴 (8개 파일)
├── 설정 화면 (10개 파일)
└── 공통 컴포넌트 (8개 파일)
Total: 53개 파일 ❌

# ✅ 올바른 예시 (적절한 크기)
feature/user-signup        # 회원가입 (15개 파일)
feature/user-profile-edit  # 프로필 편집 (12개 파일) 
feature/user-withdrawal    # 회원탈퇴 (8개 파일)
feature/user-settings      # 설정 화면 (10개 파일)
feature/user-components    # 공통 컴포넌트 (8개 파일)
```

#### 대형 작업 처리 방법

```bash
# 1단계: 기반 인프라 먼저
feature/auth-infrastructure
├── AuthError.swift
├── AuthInterface.swift  
├── AuthRepositoryImpl.swift
└── 기본 인증 구조 (20개 파일)

# 2단계: 개별 기능들
feature/auth-login         # 로그인 (25개 파일)
feature/auth-signup        # 회원가입 (30개 파일)
feature/auth-oauth         # 소셜 로그인 (28개 파일)
```

#### PR 체크리스트

**작성 전 확인:**
- [ ] 파일 변경 개수가 30개 이내인가?
- [ ] 단일 기능/버그에 집중하고 있는가?
- [ ] 관련 없는 리팩토링이 포함되어 있지 않은가?

**PR 설명 필수 항목:**
- [ ] **What**: 무엇을 변경했는가
- [ ] **Why**: 왜 변경했는가  
- [ ] **How**: 어떻게 구현했는가
- [ ] **Test**: 어떻게 테스트했는가

#### PR 템플릿

```markdown
## 📋 변경 내용
- [ ] 새 기능 추가
- [ ] 버그 수정
- [ ] 리팩토링
- [ ] 문서 업데이트
- [ ] 의존성 업데이트

## 🎯 작업 내용
<!-- 구체적인 변경 사항 나열 -->

## ✅ 테스트 완료 항목
- [ ] 로컬 빌드 성공
- [ ] 주요 기능 동작 확인
- [ ] UI 테스트 완료
- [ ] 기존 기능 영향도 확인

## 📸 스크린샷 (UI 변경 시)
<!-- Before/After 스크린샷 첨부 -->

## 📝 리뷰 포인트
<!-- 특별히 확인이 필요한 부분 -->

## 📚 참고 자료
<!-- 관련 이슈, 문서 링크 -->
```

#### 리뷰어 가이드라인

**우선순위 체크:**
1. **아키텍처 준수**: TCA + Clean Architecture 패턴
2. **에러 처리**: Result 래퍼 + 적절한 에러 타입
3. **UI 일관성**: DesignSystem 컴포넌트 사용
4. **성능**: 불필요한 렌더링, 메모리 누수 확인
5. **보안**: API 키 노출, 민감 정보 처리

**리뷰 완료 조건:**
- [ ] 모든 CI 체크 통과
- [ ] 2명 이상의 Approve 
- [ ] 충돌(Conflict) 해결 완료
- [ ] 커밋 히스토리 정리 (squash 권장)

## 🔧 개발 환경 Commands

### Make 명령어

| 명령어 | 설명 |
|--------|------|
| `./make generate` | Xcode 프로젝트 생성 |
| `./make build` | clean → install → generate 순차 실행 |
| `./make install` | 의존성 설치 |
| `./make clean` | 프로젝트 정리 |

### Xcode 빌드

```bash
# 빌드
xcodebuild -workspace DDDAttendance.xcworkspace -scheme DDDAttendance build

# 테스트 실행  
xcodebuild -workspace DDDAttendance.xcworkspace -scheme DDDAttendance test
```

### ⚠️ 중요 규칙

1. **파일 생성/삭제 시**: 반드시 `./make generate` 실행
2. **`Project.swift` 수정 시**: 반드시 `./make generate` 실행  
3. **의존성 추가/제거 시**: `./make install` → `./make generate` 순서로 실행
4. **Tuist glob 특성**: generate 없이는 Xcode에 새 파일이 반영되지 않음

## 📚 참고사항

### 테스트 패턴

```swift
// TCA TestStore 패턴
func testLogin() async {
    let store = TestStore(initialState: LoginFeature.State()) {
        LoginFeature()
    }
    
    await store.send(.loginButtonTapped) {
        $0.isLoading = true
    }
    
    await store.receive(.loginResponse(.success(mockUser))) {
        $0.isLoading = false
        $0.user = mockUser
    }
}
```

### 성능 고려사항

- **TCA State**: `@ObservableState` + `Equatable` 구현으로 불필요한 렌더링 방지
- **Effect 최적화**: `.run` 내에서 Heavy 작업 처리, UI 업데이트는 MainActor
- **의존성 주입**: 싱글톤 패턴 최소화, Interface 기반 테스트 용이성 확보

## 🚀 iOS 성능 최적화 통합 시스템

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

### 7. 두 에이전트 결과 비교 및 최적 솔루션 선택 (필수)

#### 🔍 비교 기준:
- **완성도**: 실제 작동하는 코드를 제공하는가?
- **아키텍처**: TCA/PFW 베스트 프랙티스를 따르는가?
- **성능**: 메모리 누수나 Effect 관리가 우수한가?
- **유지보수성**: 코드가 읽기 쉽고 확장 가능한가?

#### 🎯 선택 전략:
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

#### ✅ 최종 결정 프로세스:
1. **두 에이전트 동시 호출**
2. **결과 비교 및 분석** 
3. **최적 솔루션 선택 및 적용**
4. **선택 이유 명시**

### 6. 빌드 오류 해결 프로세스 (필수)
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

### 🎯 사용 가능한 스킬

#### 1. ios-performance-optimizer 
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

#### 2. ios-performance-pfw
**Point-Free Workshop 전문**
- 🏗️ TCA 아키텍처 최적화
- 📱 SwiftUI 성능 패턴
- 🧭 Swift Navigation 통합
- 🔍 PFW 라이브러리 전문

```bash
@ios-performance-pfw
```

### 🎛️ 상황별 최적 스킬 선택

#### 🔧 PFW 철학 기반 자동 최적화 (v4.0)
```bash
# PFW 패턴 우선 전체 프로젝트 최적화
@ios-performance-optimizer "PFW 단순성 원칙으로 DDDAttendance 최적화해줘 - 3개 핵심 CancelID만 사용"

# TCAFlow + PFW 패턴 마이그레이션 
@ios-performance-optimizer "PFW 철학 기반 TCAFlow 마이그레이션 - 복잡한 Effect 취소 금지"

# 타입 안전 상태 검증 자동 구현
@ios-performance-optimizer "switch (action, state) 패턴으로 ifCaseLet 오류 해결 - v3.0 복잡성 제거"
```

#### 🏗️ 아키텍처 분석이 필요한 경우  
```bash
# TCA 패턴 분석
@ios-performance-pfw "HomeFeature TCA 성능 분석해줘"

# SwiftUI 성능 최적화
@ios-performance-pfw "LazyVStack 적용 패턴 알려줘"

# Point-Free 라이브러리 활용
@ios-performance-pfw "IdentifiedArray 성능 최적화 방법"
```

### 🔄 협업 워크플로우

#### 1단계: 분석 (ios-performance-pfw)
```bash
@ios-performance-pfw "HomeView 성능 분석하고 개선점 찾아줘"
```

#### 2단계: 자동 적용 (ios-performance-optimizer)
```bash
@ios-performance-optimizer "분석 결과 기반으로 자동 최적화해줘"
```

#### 3단계: 통합 검증
```bash
# 두 스킬 결과 통합 확인
@ios-performance-pfw "자동 최적화 후 TCA 패턴 검증해줘"
```

### 📊 기능별 비교표 (v4.0 업데이트)

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

### 🎯 DDDAttendance 특화 사용법

#### HomeView 스크롤 성능 이슈
```bash
# 1. PFW로 정확한 분석
@ios-performance-pfw "HomeView LazyVStack 성능 분석해줘"

# 2. 자동화 도구로 적용
@ios-performance-optimizer "LazyVStack 최적화 자동 적용해줘"
```

#### TCA Store 메모리 누수
```bash
# 1. PFW로 아키텍처 검증
@ios-performance-pfw "ExploreFeature Effect 취소 패턴 분석해줘" 

# 2. 자동화로 수정
@ios-performance-optimizer "TCA Effect 메모리 누수 자동 수정해줘"
```

#### 빌드 시간 최적화
```bash
# 1. PFW로 의존성 분석
@ios-performance-pfw "모듈 의존성 구조 분석해줘"

# 2. 자동화로 Tuist 최적화
@ios-performance-optimizer "Tuist 빌드 시간 자동 최적화해줘"
```

### 🚀 고급 활용 패턴

#### 연속 호출 패턴
```bash
# A → B → A 패턴 (분석 → 적용 → 검증)
@ios-performance-pfw "전체 아키텍처 분석해줘"
# ↓ 
@ios-performance-optimizer "분석 기반 자동 최적화해줘"  
# ↓
@ios-performance-pfw "최적화 결과 TCA 패턴 검증해줘"
```

#### 병렬 호출 패턴
```bash
# 동시에 다른 관점에서 분석
@ios-performance-pfw "SwiftUI 성능 분석해줘"
@ios-performance-optimizer "메모리 누수 자동 검사해줘"
```

### 📋 체크리스트

#### 성능 최적화 전
- [ ] `@ios-performance-pfw`로 아키텍처 분석 완료
- [ ] 성능 병목 지점 식별 완료
- [ ] Point-Free 패턴 적용 가능성 확인

#### 자동 최적화 시
- [ ] `@ios-performance-optimizer`로 자동 분석 실행
- [ ] 개선 계획 검토 및 승인
- [ ] 자동 코드 수정 완료

#### 최적화 후
- [ ] `@ios-performance-pfw`로 패턴 검증
- [ ] 성능 개선 효과 측정
- [ ] 추가 최적화 필요성 검토

### 🎉 결론 (v4.0 업데이트)

**🚀 PFW 철학 통합으로 더욱 강력해진 최적 조합:**
1. **정확한 분석**: `@ios-performance-pfw`의 **Point-Free 전문성** + v4.0 이론적 뒷받침
2. **빠른 적용**: `@ios-performance-optimizer v4.0`의 **PFW 기반 자동화 시스템**
3. **품질 보증**: **PFW 철학을 공유**하는 두 스킬의 **완벽한 교차 검증**

**🎯 v4.0 핵심 개선:**
- ✅ **복잡성 제거**: v3.0의 40개 Effect 차단 → 3개 핵심 CancelID
- ✅ **PFW 우선**: performAtomicStateTransition 제거 → 단순 튜플 매칭
- ✅ **타입 안전**: 수동 검증 → 자동 `switch (action, state)` 구현

**DDDAttendance 프로젝트에서 PFW 철학이 통합된 이 두 스킬을 조합하면 iOS 성능 최적화의 완벽한 솔루션을 얻을 수 있습니다!** 🚀

---

이 문서는 DDDAttendance iOS 프로젝트의 **아키텍처 가이드라인**입니다. 
새로운 기능 개발이나 코드 리뷰 시 이 가이드를 참고하여 일관성 있는 코드를 작성해주세요.