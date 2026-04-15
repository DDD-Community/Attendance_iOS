# TCA (The Composable Architecture) 패턴 가이드

## 🔄 기본 구조

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

## 📏 TCA 규칙

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

## 🔧 TCA Extension 패턴 (실제 프로젝트 활용법)

### 1. Action 처리 메서드 분리

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
}
```

### 2. State Extension (Computed Properties)

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
}
```

### 3. Coordinator Extension 패턴

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
      
    default:
      return .none
    }
  }
}
```

## 📋 Extension 활용 규칙

1. **Action 핸들러**: 각 Action 타입별로 `handle{ActionType}Action` 메서드로 분리
2. **State 로직**: 복잡한 계산은 computed property로 extension에 분리
3. **네이밍**: `handle` + `{ActionType}` + `Action` 패턴 준수
4. **접근 제어**: 핸들러 메서드는 `private` 사용
5. **파일 구성**: extension은 `// MARK: -` 주석으로 구분
6. **의존성**: extension 내에서도 `@Dependency` 직접 사용 가능

## 🧪 테스트 패턴

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

**이 가이드는 에이전트들이 TCA 패턴을 분석하고 최적화할 때 참고하는 기준입니다.**