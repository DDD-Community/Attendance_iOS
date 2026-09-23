# 조립 엣지 계층 방향 정렬 (Assembly Edge Alignment)

- 날짜: 2026-09-02
- 범위: `Data/DataAssembly/Project.swift`, `Feature/FeatureAssembly/Project.swift`
- 계기: Joongna iOS 모듈 그래프와의 구조 비교

## 문제

현재 조립 사슬이 계층 방향과 반대다.

```
App → FeatureAssembly → DataAssembly → { DomainAssembly, ServiceAssembly }
```

`DataAssembly`(Data 계층)가 `DomainAssembly`(Domain 계층) 위에 있다. `DomainAssembly`는
`@_exported import UseCase` 를 하므로, 결과적으로 **Data 계층이 Domain 의 UseCase 구현을 링크**한다.
UseCase 는 Data 보다 상위 계층이므로 의존 방향 역행이다.

근거:

- `Projects/Data/DataAssembly/Project.swift` — `dependencies` 에 `.domainAssembly` 포함
- `Projects/Domain/DomainAssembly/Sources/DomainAssemblyExported.swift` — `@_exported import UseCase`
- `Projects/App/Project.swift:20-23` — App 은 `.featureAssembly` 하나만 의존

## 관찰: DataAssembly 는 DomainAssembly 를 소스 수준에서 쓰지 않는다

`Data/DataAssembly/Sources` 의 import 전수:

```
Repository, ServiceAssembly, Model, DDDNetworkInterface, Dependencies, DomainInterface
```

`UseCase` 도 `DomainAssembly` 도 import 하지 않는다. `DataAssembly` 의 실제 역할은
Repository 구현을 `DomainInterface` 의 `DependencyKey` 에 `liveValue` 로 꽂는 것이며
(`DependencyValues+{Attendance,Vote,OnBoarding,Profile,Auth}.swift`),
여기에 필요한 것은 `DomainInterface` 뿐이다. `Entity` 는 직접 import 하지 않으므로 추가하지 않는다.

따라서 `.domainAssembly` 의존은 소스 요구가 아니라 **링크 그래프 유지 목적**으로만 존재한다.
App 타깃의 `OTHER_LDFLAGS` 가 `-force_load $(BUILT_PRODUCTS_DIR)/UseCase.framework/UseCase` 를
지정하므로(`Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/Project+Template.swift:26`)
`UseCase.framework` 가 그래프 안에 있어야 하는데, 현재는 그 경로가 DataAssembly 를 통한다.

## 설계

조립 루트를 위로 올려서 각 Assembly 가 자기 계층 아래로만 내려가게 한다.

**변경 1 — `Projects/Data/DataAssembly/Project.swift`**

```
.domainAssembly  →  .domain(.domainInterface)
```

**변경 2 — `Projects/Feature/FeatureAssembly/Project.swift`**

`dependencies` 에 `.domainAssembly` 추가. FeatureAssembly 는 Feature 계층이므로
Domain 을 향하는 하향 의존이고, App 이 아는 유일한 모듈이라 조립 루트로 적합하다.

변경 후:

```
App → FeatureAssembly → { Feature×8, DomainAssembly, DataAssembly }
                            DataAssembly → { Repository, Model, DomainInterface, ServiceAssembly }
```

`App/Project.swift` 는 수정하지 않는다. App 은 계속 `.featureAssembly` 하나만 안다.

## 검증 기준

1. `tuist generate` 성공
2. `UseCase.framework` 가 App 링크 그래프에 남아 있어 `-force_load` 가 해결됨 → 앱 빌드 성공
3. `Data/DataAssembly/Tests/Sources/LiveDependencyRegistrationTests.swift` 통과
   (live `DependencyKey` 등록이 깨지지 않았음을 보장)
4. 전체 테스트 스위트가 변경 전과 동일한 결과
5. `tuist graph` 에서 `DataAssembly → DomainAssembly` 엣지 소멸, `FeatureAssembly → DomainAssembly` 엣지 등장

## 이번 범위에서 제외 (분석 결과 보존)

### Feature → UseCase 디커플링

당초 목표였던 빌드 시간 단축·테스트 격리는 이 작업으로는 달성되지 않는다.
Feature 8개가 `.domainAssembly` 를 의존하고, `DomainAssembly` 가 `UseCase` 를 re-export 하므로
UseCase 구현을 고치면 Feature 8개가 재빌드된다.

끊으려면 UseCase 레벨 DI 표면을 `DomainInterface` 로 옮겨야 한다. 현황:

- **형태 1 (~8파일)** — Vote, Attendance, Schedule, Auth, QRCode, OnBoarding, OAuth 등.
  프로토콜은 이미 `DomainInterface` 에 있고(`VoteUseCaseImpl: VoteInterface`),
  `UseCase` 에는 키(`VoteUseCaseImpl.self`)와 `DependencyValues` 접근자만 있다.
- **형태 2 (~4파일)** — Profile, AppUpdate, MyPage×2.
  프로토콜(`ProfileUseCaseInterface`)까지 `UseCase` 안에 있다.

목표 형태 (이미 `DomainInterface` 의 Repository 계약이 쓰는 관례와 동일):

```swift
// DomainInterface
public enum VoteUseCaseDependency: TestDependencyKey { … }
public extension DependencyValues {
  var voteUseCase: VoteInterface { get { self[VoteUseCaseDependency.self] } set { … } }
}
// UseCase
extension VoteUseCaseDependency: DependencyKey {
  public static var liveValue: VoteInterface { VoteUseCaseImpl() }
}
```

추가로 `Feature/Member/Sources/MemberMain/Reducer/MemberMain.swift:108-109` 의
`@Dependency(ProfileUseCaseImpl.self)` / `@Dependency(AttendanceUseCaseImpl.self)` 를
키 enum 참조로 교체해야 한다.

추정 규모 ~30파일. **부분 적용은 이득이 없다** — 12개 키 중 하나라도 `UseCase` 에 남으면
Feature 는 여전히 `UseCase` 를 링크하므로 빌드 시간·테스트 격리 효과가 나오지 않는다.

### Feature Interface / Demo 모듈

Joongna 는 Feature 마다 `XInterface` / `XTesting` / `XDemo` 를 둔다.
Attendance 는 **Feature 간 의존 엣지가 0개**라 Interface 로 끊을 대상이 없다.
Joongna 가 Feature Interface 를 둔 이유는 Chatting↔Store 처럼 Feature 끼리 서로 참조하기 때문이다.
현재 구조에서는 모듈 수만 8→24 로 늘고 실익이 없으므로 채택하지 않는다.

템플릿(`Project+Template.swift:158-207`)은 `hasInterface` / `hasTesting` /
`interfaceDependencies` / `testDependencies` 를 이미 지원하므로,
나중에 필요해지면 플러그인 작업 없이 매니페스트만으로 도입할 수 있다.

### 별건으로 발견된 것

- `Projects/Data/{API,Service,ServiceAssembly}`, `Projects/Shared/{DesignSystem,Shareds,ThirdParty,Utill}`
  는 `Plugins/DependencyPlugin/.../Modules.swift` 카탈로그에 없고 `Project.swift` 도 없다.
  `.xcodeproj` / `Derived` 잔재만 남은 유령 디렉토리 → 별도 커밋으로 삭제 권장.
- `Domain/UseCase/Sources/SignUp/ SignUpUseCaseImpl.swift` — 파일명 앞에 공백이 있다.
- `VoteUseCaseImpl` 과 `VoteRepositoryDependency` 가 같은 `VoteInterface` 프로토콜을 공유한다.
  UseCase 가 Repository 패스스루라는 뜻으로, 계층 하나가 값을 더하지 않고 있을 수 있다.
