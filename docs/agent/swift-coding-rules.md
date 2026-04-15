# Swift 코딩 규칙 가이드

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

## ⚠️ 에러 처리

### Domain Error 구조

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

### 표준 에러 구조

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

### TCA에서 에러 처리 패턴

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

## 📋 에러 처리 규칙

1. **에러 타입 정의**: 기능별로 Domain/Entity/Sources/Error/에 위치
2. **`LocalizedError` 구현**: 사용자에게 보여줄 메시지 제공
3. **`from(_:)` 메서드**: 모든 에러를 해당 Feature 에러로 변환
4. **상태 기반 분류**: `isRetryable`, `isNetworkError` 등으로 UI 로직 분리
5. **TCA Result 패턴**: `.mapError(FeatureError.from)` 필수 사용

## 🎯 테스트 패턴

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

## 🔧 성능 고려사항

- **TCA State**: `@ObservableState` + `Equatable` 구현으로 불필요한 렌더링 방지
- **Effect 최적화**: `.run` 내에서 Heavy 작업 처리, UI 업데이트는 MainActor
- **의존성 주입**: 싱글톤 패턴 최소화, Interface 기반 테스트 용이성 확보

**이 가이드는 에이전트들이 Swift 코드 품질을 분석하고 최적화할 때 참고하는 기준입니다.**