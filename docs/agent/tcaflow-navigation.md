# TCAFlow 네비게이션 가이드

## 🧭 TCAFlow 네비게이션 패턴

TCAFlow @FlowCoordinator를 활용한 네비게이션 관리 시스템

### @FlowCoordinator 기본 구조

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

### 기본 네비게이션 동작

#### Push/Present/Dismiss 패턴

```swift
// Push Navigation
state.routes.push(.screenA(.init()))

// Present Modal
state.routes.present(.screenB(.init()))

// Go Back
state.routes.goBack()

// Go Back to Root
state.routes.goBackToRoot()

// Replace Current Screen
state.routes.replaceCurrent(.screenC(.init()))
```

#### 지연된 라우팅 (애니메이션 충돌 방지)

```swift
return routeWithDelaysIfUnsupported(state.routes, action: \.router) {
    $0.push(.nextScreen(.init()))
}
```

### 화면 간 통신 패턴

#### 자식 → 부모 통신 (Delegate Action)

```swift
// 자식에서 부모로 이벤트 전달
case .routeAction(id: _, action: .login(.delegate(.presentMain))):
    return .send(.navigation(.presentMain))

case .routeAction(id: _, action: .profile(.delegate(.logout))):
    return .send(.inner(.performLogout))
```

#### 부모 → 자식 통신 (State 업데이트)

```swift
// 부모에서 자식 Feature의 상태 업데이트
case .routeAction(id: _, action: .profile(.inner(.updateUserInfo(let info)))):
    // 자식 Feature의 상태를 부모에서 관리
    return .none
```

### Coordinator Extension 패턴

#### Router Action 핸들링

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
}
```

#### Navigation Action 핸들링

```swift
extension AuthCoordinator {
  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentMain:
      // 부모 Coordinator로 전달
      return .send(.delegate(.presentMainApp))
      
    case .dismissAuth:
      state.routes.goBackToRoot()
      return .none
    }
  }
}
```

### 네비게이션 상태 관리

#### Route Stack 관리

```swift
// Routes 배열을 통한 네비게이션 스택 관리
public struct State: Equatable {
    var routes: [Route<FeatureScreen.State>] = []
    
    // Navigation Helper Properties
    var currentRoute: FeatureScreen.State? {
        routes.last?.screen
    }
    
    var navigationDepth: Int {
        routes.count
    }
    
    var isAtRoot: Bool {
        routes.count <= 1
    }
}
```

#### 조건부 네비게이션

```swift
// 로그인 상태에 따른 조건부 라우팅
case .authStatusChanged(let isLoggedIn):
  if isLoggedIn {
    state.routes.push(.main(.init()))
  } else {
    state.routes.goBackToRoot()
    state.routes.push(.login(.init()))
  }
  return .none
```

### 딥 링크 처리

#### URL 기반 네비게이션

```swift
case .handleDeepLink(let url):
  switch url.path {
  case "/profile":
    state.routes.goBackToRoot()
    state.routes.push(.profile(.init()))
    
  case "/settings":
    state.routes.goBackToRoot()
    state.routes.push(.settings(.init()))
    
  default:
    break
  }
  return .none
```

### 네비게이션 애니메이션 제어

#### 커스텀 전환 애니메이션

```swift
// Push with custom animation
state.routes.push(.nextScreen(.init()), animation: .slide)

// Present with custom animation  
state.routes.present(.modal(.init()), animation: .fade)
```

### 오류 처리 및 복구

#### 네비게이션 오류 처리

```swift
case .navigationError(let error):
  // 네비게이션 스택 복구
  if state.routes.isEmpty {
    state.routes = [.root(.login(.init()), embedInNavigationView: true)]
  }
  
  // 에러 알림 표시
  state.errorAlert = .navigationError(error)
  return .none
```

### 테스트 패턴

#### TCAFlow Navigation 테스트

```swift
func testNavigationFlow() async {
  let store = TestStore(
    initialState: AppCoordinator.State()
  ) {
    AppCoordinator()
  }
  
  // 초기 화면 확인
  XCTAssertEqual(store.state.routes.count, 1)
  
  // 네비게이션 테스트
  await store.send(.view(.navigateToProfile)) {
    $0.routes.append(.init(.profile(.init())))
  }
  
  // 뒤로 가기 테스트
  await store.send(.view(.navigateBack)) {
    $0.routes.removeLast()
  }
}
```

## 📋 TCAFlow 네비게이션 규칙

1. **@FlowCoordinator 매크로**: 모든 Coordinator에 필수 사용
2. **Route Stack 관리**: `routes` 배열을 통한 네비게이션 스택 제어
3. **Delegate 패턴**: 자식 → 부모 통신은 delegate action 활용
4. **Extension 분리**: Router/Navigation action 핸들러는 extension으로 분리
5. **애니메이션 충돌 방지**: `routeWithDelaysIfUnsupported` 사용
6. **상태 기반 라우팅**: 앱 상태에 따른 조건부 네비게이션
7. **딥 링크 지원**: URL 기반 네비게이션 처리

**이 가이드는 에이전트들이 TCAFlow 네비게이션을 분석하고 최적화할 때 참고하는 기준입니다.**