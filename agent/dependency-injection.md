# DI (Dependency Injection) with WeaveDI 가이드

## 🔄 의존성 주입 패턴

WeaveDI를 활용한 Clean Architecture 기반 의존성 주입 시스템

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

#### Repository에서 의존성 주입

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
```

#### TCA Feature에서 의존성 사용

```swift
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

#### UseCase에서 의존성 주입

```swift
// UseCase에서 Repository 의존성 사용
public final class AuthUseCase {
  @Dependency(\.authRepository) private var authRepository
  @Dependency(\.profileRepository) private var profileRepository
  
  public func loginUser(request: LoginRequest) async throws -> UserEntity {
    let loginResponse = try await authRepository.login(request: request)
    let profile = try await profileRepository.fetchProfile(userId: loginResponse.userId)
    
    return UserEntity(
      id: loginResponse.userId,
      email: loginResponse.email,
      profile: profile
    )
  }
}
```

### 의존성 등록 규칙

1. **Interface 기반 등록**: 구체 타입이 아닌 Protocol로 등록
2. **계층별 분리**: Repository, UseCase, Provider별로 주석으로 그룹화  
3. **생성자 주입**: `@Dependency` 프로퍼티 래퍼 활용
4. **싱글톤 관리**: `AppDIManager.shared`로 전역 관리

### WeaveDI 3.4.1 특화 패턴

#### 조건부 등록

```swift
WeaveDI.builder
    .register { 
        if ProcessInfo.processInfo.environment["TESTING"] != nil {
            return MockAuthRepository() as AuthInterface
        } else {
            return AuthRepositoryImpl() as AuthInterface
        }
    }
    .configure()
```

#### 스코프 관리

```swift
WeaveDI.builder
    // 싱글톤 등록
    .register(scope: .singleton) { NetworkManager() as NetworkManaging }
    
    // 새 인스턴스 생성
    .register(scope: .transient) { DateFormatter() }
    
    .configure()
```

#### Factory 패턴

```swift
WeaveDI.builder
    .register { 
        AuthRepositoryFactory() as AuthRepositoryFactoryInterface 
    }
    .register { 
        let factory = WeaveDI.resolve(AuthRepositoryFactoryInterface.self)
        return factory.createRepository() as AuthInterface
    }
    .configure()
```

### TCA Dependencies 통합

#### Dependency Key 정의

```swift
// AuthRepository Dependency Key
extension DependencyValues {
  var authRepository: AuthInterface {
    get { self[AuthRepositoryKey.self] }
    set { self[AuthRepositoryKey.self] = newValue }
  }
}

private enum AuthRepositoryKey: DependencyKey {
  static let liveValue: AuthInterface = WeaveDI.resolve(AuthInterface.self) ?? AuthRepositoryImpl()
  static let testValue: AuthInterface = MockAuthRepository()
}
```

#### 테스트에서 Mock 주입

```swift
func testLogin() async {
  let store = TestStore(
    initialState: LoginFeature.State()
  ) {
    LoginFeature()
  } withDependencies: {
    $0.authRepository = MockAuthRepository()
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

### 의존성 초기화 순서

#### App 진입점에서 초기화

```swift
@main
struct DDDAttendanceApp: App {
  init() {
    Task {
      await AppDIManager.shared.registerDefaultDependencies()
    }
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
```

#### 계층별 초기화 순서

```swift
public func registerDefaultDependencies() async {
    // 1단계: 기반 인프라
    WeaveDI.builder.register { KeychainManager() as KeychainManagingInterface }
    
    // 2단계: 네트워크 & 토큰 관리
    WeaveDI.builder.register { 
        TokenProvider(keychainManager: WeaveDI.resolve(KeychainManagingInterface.self)!) as TokenProviding
    }
    
    // 3단계: Repository 계층
    WeaveDI.builder.register { AuthRepositoryImpl() as AuthInterface }
    WeaveDI.builder.register { ProfileRepositoryImpl() as ProfileInterface }
    
    // 4단계: UseCase 계층
    WeaveDI.builder.register { AuthUseCase() as AuthUseCaseInterface }
    
    WeaveDI.builder.configure()
}
```

## 📋 DI 패턴 규칙

### Interface 설계 원칙

1. **단일 책임**: 각 Repository는 하나의 Domain 영역만 담당
2. **의존성 역전**: Repository Interface는 Domain 계층에 위치
3. **테스트 가능성**: Mock 구현체로 쉽게 교체 가능
4. **비동기 처리**: async/await 패턴으로 일관성 있게 구현

### Repository Interface 예시

```swift
// Domain/DomainInterface/Sources/AuthInterface.swift
public protocol AuthInterface {
  func login(request: LoginRequest) async throws -> LoginResponse
  func logout() async throws
  func refreshToken() async throws -> TokenResponse
  func validateToken() async throws -> Bool
}

// Data/Repository/Sources/AuthRepositoryImpl.swift
public final class AuthRepositoryImpl: AuthInterface {
  @Dependency(\.keychainManager) private var keychainManager
  @Dependency(\.networkManager) private var networkManager
  
  public func login(request: LoginRequest) async throws -> LoginResponse {
    // 구현
  }
}
```

### 에러 처리 통합

```swift
// Repository에서 도메인 에러로 변환
public func login(request: LoginRequest) async throws -> LoginResponse {
  do {
    let response = try await networkManager.request(.login(request))
    return response
  } catch let networkError {
    throw AuthError.from(networkError)
  }
}
```

**이 가이드는 에이전트들이 의존성 주입 패턴을 분석하고 최적화할 때 참고하는 기준입니다.**