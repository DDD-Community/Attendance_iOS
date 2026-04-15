# DI (Dependency Injection) with WeaveDI 3.4.1 가이드

## 🚀 **PFW + WeaveDI 3.4.1 통합 의존성 주입**

Point-Free Workshop 철학과 WeaveDI 3.4.1을 결합한 Clean Architecture 기반 의존성 주입 시스템

### 🎯 실제 AppDIManager 구조 (Projects/App/Sources/Di/DiRegister.swift)

```swift
/// 🚀 **PFW + WeaveDI 3.4.1 통합 DI 관리자**
@MainActor
public final class AppDIManager {
  public static let shared = AppDIManager()

  private init() {}

  /// 🎯 PFW 철학 + WeaveDI 3.4.1 패턴으로 의존성 등록
  public func registerDefaultDependencies() async {
    WeaveDI.builder
      // 🔧 인프라 계층 (PFW 단순성 원칙)
      .register { KeychainManager() as KeychainManaging }
      .register {
        let keychainManager = UnifiedDI.resolve(KeychainManaging.self) ?? KeychainManager()
        return KeychainTokenProvider(keychainManager: keychainManager) as TokenProviding
      }

      // 🏗️ Repository 계층 (Clean Architecture + PFW)
      .register { AuthRepositoryImpl() as AuthInterface }
      .register { ProfileRepositoryImpl() as ProfileInterface }
      .register { AppUpdateRepositoryImpl() as AppUpdateInterface }

      // 🔐 OAuth Provider 계층 (PFW 조합 패턴)
      .register { GoogleOAuthRepositoryImpl() as GoogleOAuthInterface }
      .register { AppleLoginRepositoryImpl() as AppleAuthRequestInterface }
      .register { AppleOAuthRepositoryImpl() as AppleOAuthInterface }
      .register { AppleOAuthProvider() as AppleOAuthProviderInterface }
      .register { GoogleOAuthProvider() as GoogleOAuthProviderInterface }

      // 📝 비즈니스 로직 계층 (PFW 단일 책임)
      .register { OnBoardingRepositoryImpl() as OnBoardingInterface }
      .register { SignUpRepositoryImpl() as SignUpInterface }
      .register { AttendanceRepositoryImpl() as AttendanceInterface }
      .register { MyPageRepositoryImpl() as MyPageRepositoryInterface }
      .register { ScheduleRepositoryImpl() as ScheduleInterface }
      .register { QRCodeRepositoryImpl() as QRCodeInterface }

      .configure()
  }
}
```

### 🔥 실제 프로젝트 DI 사용 패턴

#### 1. **Repository 구현체에서 @Dependency 사용**
*실제 코드: Projects/Data/Repository/Sources/Auth/Repository/AuthRepositoryImpl.swift*

```swift
final public class AuthRepositoryImpl: AuthInterface, @unchecked Sendable {
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

  // MARK: - 로그인 API
  public func login(
    provider socialProvider: SocialType,
    token: String
  ) async throws -> LoginEntity {
    let dto: LoginResponseDTO = try await provider.request(
      .login(body: OAuthLoginRequest(provider: socialProvider.description, token: token))
     )
    return dto.toDomain()
  }

  // MARK: - 토큰 재발급
  public func refresh() async throws -> AuthTokens {
    let refreshToken = keychainManager.refreshToken() ?? ""
    // keychainManager는 @Dependency로 주입받아 사용
    let dto: TokenDTO = try await provider.request(.refresh(refreshToken: refreshToken))
    return dto.toDomain()
  }
}
```

#### 2. **TCA Feature에서 @Dependency 사용**
*실제 코드: Projects/Presentation/Auth/Sources/Login/Reducer/Login.swift*

```swift
@Reducer
public struct Login {
  @Dependency(\.appleManger) var appleLoginManger
  @Dependency(\.unifiedOAuthUseCase) var unifiedOAuthUseCase
  @Dependency(\.continuousClock) var clock

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .async(.login(let socialType)):
        return .run { [userSession = state.userSession] send in
          let result = try await unifiedOAuthUseCase.login(
            socialType: socialType,
            userSession: userSession
          )
          await send(.inner(.loginResponse(.success(result))))
        }
      }
    }
  }
}
```

#### 3. **TokenProvider 구조체 패턴**
*실제 코드: Projects/App/Sources/Di/KeychainTokenProvider.swift*

```swift
struct KeychainTokenProvider: TokenProviding {
  private let keychainManager: KeychainManaging

  init(keychainManager: KeychainManaging) {
    self.keychainManager = keychainManager
  }

  func accessToken() -> String? {
    keychainManager.accessToken()
  }

  func saveAccessToken(_ token: String) {
    keychainManager.saveAccessToken(token)
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

## 🎯 **PFW + WeaveDI 3.4.1 철학**

### Point-Free Workshop 원칙 적용

#### 1. **단순성 (Simplicity)**
- **최소한의 의존성**: 꼭 필요한 인터페이스만 주입
- **명확한 책임**: 각 Repository는 단일 Domain 영역만 담당
- **PFW 주석**: 코드에서 PFW 철학을 명시적으로 표현

```swift
WeaveDI.builder
  // 🔧 인프라 계층 (PFW 단순성 원칙)
  .register { KeychainManager() as KeychainManaging }
  
  // 🏗️ Repository 계층 (Clean Architecture + PFW)
  .register { AuthRepositoryImpl() as AuthInterface }
```

#### 2. **조합가능성 (Composability)**
- **Interface 기반**: 구체 타입 대신 Protocol 등록
- **계층별 분리**: 인프라 → Repository → OAuth → 비즈니스 로직 순서
- **의존성 체인**: 하위 의존성을 조합해서 상위 의존성 구성

```swift
.register {
  let keychainManager = UnifiedDI.resolve(KeychainManaging.self) ?? KeychainManager()
  return KeychainTokenProvider(keychainManager: keychainManager) as TokenProviding
}
```

#### 3. **예측가능성 (Predictability)**
- **@MainActor 안전성**: AppDIManager는 MainActor에서 실행
- **타입 안전성**: 컴파일 타임에 의존성 검증
- **에러 처리**: nil coalescing으로 기본값 제공

### WeaveDI 3.4.1 + Swift 6 호환성

#### @unchecked Sendable 패턴
```swift
final public class AuthRepositoryImpl: AuthInterface, @unchecked Sendable {
  @Dependency(\.keychainManager) private var keychainManager
  // Swift 6 Concurrency 안전성 보장
}
```

#### nonisolated 접근 패턴
```swift
@MainActor
public final class AppDIManager {
  nonisolated public static let shared = AppDIManager()
  
  public func registerDefaultDependencies() async {
    // MainActor에서 안전하게 의존성 등록
  }
}
```

### 실무 활용 팁

#### 1. **앱 시작 시 초기화**
```swift
@main
struct DDDAttendanceApp: App {
  init() {
    Task {
      await AppDIManager.shared.registerDefaultDependencies()
    }
  }
}
```

#### 2. **테스트에서 Mock 주입**
```swift
func testLogin() async {
  let store = TestStore(initialState: Login.State()) {
    Login()
  } withDependencies: {
    $0.unifiedOAuthUseCase = MockOAuthUseCase()
  }
}
```

#### 3. **Debug/Release 분기**
```swift
WeaveDI.builder
  .register {
    #if DEBUG
    return DebugKeychainManager() as KeychainManaging
    #else
    return KeychainManager() as KeychainManaging
    #endif
  }
```

---

**🚀 이 가이드는 ios-performance-optimizer와 ios-performance-pfw 에이전트들이 의존성 주입 패턴을 분석하고 최적화할 때 참고하는 실제 프로젝트 기준입니다.**