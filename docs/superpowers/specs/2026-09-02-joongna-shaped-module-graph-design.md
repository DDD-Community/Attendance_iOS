# Joongna 형태 모듈 그래프로의 재편 설계

- 날짜: 2026-09-02
- 목표: Joongna iOS 모듈 그래프(Interface / Testing / Demo 3분할)를 Attendance에 적용
- 제약: Domain·Data 계층은 유지한다(사용자 지시). 테스트 호스트 앱은 만들지 않는다.

## Joongna와 Attendance의 구조적 차이

Joongna는 Domain/Data 계층이 없다. `Feature → FeatureInterface → ServiceAssembly` 로 끝난다.
Attendance는 `Entity / DomainInterface / UseCase / Model / Repository` 를 갖고 있고 이를 유지한다.

따라서 목표는 **Joongna의 Feature 쪽 모양 + Attendance의 Domain/Data 계층** 하이브리드다.
Joongna에 있는 `JNAnalytics` / `JNConfig` / `JNAccessibility` 는 Attendance에 대응 모듈이
없으므로 만들지 않는다.

## 현재 상태

- Interface 보유: `DDDNetwork`, `DDDStorage`, `DDDAuth` (3개)
- Testing 보유: `Repository`, `UseCase` (2개)
- Demo: 0개
- 템플릿(`Project+Template.swift`)은 `hasInterface` / `interfaceDependencies` / `hasTesting` 지원.
  **Demo 앱 생성은 지원하지 않는다.**

## 목표 그래프

```
DDDAttendanceTests → DDDAttendance → FeatureAssembly
                                       ├── Auth / Management / Member / OnBoarding / Profile / Splash / Web
                                       ├── FeatureSharedUI
                                       ├── DomainAssembly
                                       └── DataAssembly

각 Feature X 마다:
  XInterface   공개 계약(라우트·진입점·다른 피처가 쓰는 값 타입)
  X            구현            → XInterface
  XTesting     테스트 더블      → XInterface
  XTests       테스트          → X, XTesting
  XDemo        단독 실행 앱     → X

UI:      DDDSharedUI → DDDDesignKit, DDDAnimation
         DDDDesignKitDemo → DDDDesignKit          (JNDesignKitDemo 대응)

Domain:  DomainAssembly → Entity, DomainInterface, UseCase(+Testing)
Data:    DataAssembly   → Model, Repository(+Testing), DomainInterface
Service: ServiceAssembly → DDDAuth(+Interface), API, APIEndpoint
Core:    CoreAssembly   → DDDCoreUI, DDDCoreUtility, DDDCoreLogger, DDDThirdParty,
                          DDDNetwork(+Interface), DDDStorage(+Interface)
```

## Feature Interface 의 내용 규약

TCA 피처는 Reducer 자체가 구현이라 "Interface에 Reducer를 둔다"가 성립하지 않는다.
`XInterface` 에 넣는 것을 다음으로 한정한다.

- 다른 피처·조립 루트가 참조하는 **라우트/목적지 타입** (`public enum XRoute`)
- 피처 진입에 필요한 **입력 값 타입** (화면에 넘기는 파라미터)
- 피처가 외부에 알리는 **Delegate Action** 정의
- 위를 소비하는 쪽이 쓰는 `DependencyKey` (테스트값만; live 는 구현 모듈에서 등록)

`XInterface` 에 넣지 않는 것: Reducer, View, State 전체.
이들은 구현 상세이며 Interface 로 올리면 Interface 가 구현을 그대로 복제하게 된다.

## 작업 규모

| 항목 | 신규 타깃 | 비고 |
|---|---|---|
| 템플릿 Demo 지원 | - | `hasDemo` 파라미터 + Demo 앱 타깃 생성 |
| Feature Interface × 7 | 7 | 타입 이동이 실제 작업 |
| Feature Testing × 7 | 7 | XInterface 의 더블 |
| Feature Demo × 7 | 7 | 단독 실행 앱 |
| DDDDesignKitDemo | 1 | |
| 합계 | **22** | 현재 34 → 약 56 프로젝트 |

## 단계

각 단계는 독립 커밋이고, 단계가 끝날 때마다 `tuist generate` + 전체 스위트가 통과해야 한다.

1. **템플릿에 Demo 지원 추가** — `hasDemo` / `demoDependencies`. 검증: 기존 그래프 무변화.
2. **DDDDesignKitDemo 1개로 파일럿** — Demo 앱이 실제로 뜨는지 확인. 가장 의존성이 얕다.
3. **Feature 1개(Splash) 로 Interface/Testing/Demo 3분할 파일럿** — 규약이 실제로 성립하는지 확인.
   Splash 는 의존성이 가장 얕아 실패 비용이 작다.
4. **나머지 Feature 6개 확산** — 피처당 1커밋.
5. **FeatureAssembly 를 XInterface 기준으로 정리**

## 구현 중 확인된 사실

### Demo 는 별도 스킴이 생기지 않는다

Tuist 의 기본 스킴 그룹핑(`.byNameSuffix`)이 `Demo` 접미사를 **base 스킴의 run 타깃**으로 묶는다.
`DDDDesignKitDemo` 를 만들어도 `DDDDesignKitDemo` 스킴은 생기지 않고,
`DDDDesignKit` 스킴 하나가 구현·Demo·Tests 를 모두 빌드하고 실행 시 Demo 를 띄운다.

```
DDDDesignKit.xcscheme
  BuildAction  : DDDDesignKit, DDDDesignKitDemo, DDDDesignKitTests
  LaunchAction : DDDDesignKitDemo
```

따라서:

- 개발자는 `X` 스킴을 골라 Run 하면 Demo 가 뜬다. 별도 스킴 정의가 필요 없다.
- CI 에서 Demo 만 빌드하려면 스킴이 아니라 `-target XDemo` 를 쓰거나
  명시적 스킴을 따로 정의해야 한다. 이는 "Demo 를 CI 필수 빌드에서 제외할지" 결정과 맞물린다.
- `X` 스킴 빌드가 이제 Demo 까지 빌드하므로, 모듈 단위 빌드 시간이 늘어난다.

### Interface 와 Testing 은 한 세트다

`XTesting` 은 일반 타깃이라 `@testable` 을 쓸 수 없다. 대상 모듈의 **public API 만** 참조할 수 있다.

Splash 파일럿에서 `SplashFixture.completedState()` 가
`'staffRole' is inaccessible due to 'internal' protection level` 로 컴파일에 실패했다.
`Splash.State` 의 프로퍼티가 internal 이기 때문이다. 선택지는 둘뿐이다.

- 대상 모듈의 State/프로퍼티를 public 으로 넓힌다 → 캡슐화 손해
- Testing 은 public 계약 기준의 더블만 담는다 → **그 계약이 곧 Interface 다**

Joongna 그래프에서 `XTesting` 이 `X` 가 아니라 `XInterface` 를 가리키는 이유가 이것이다.
Interface 없이 Testing 만 도입하면 public 타입 픽스처 몇 개짜리로 쪼그라든다.
실제로 `SplashTesting` 은 `Entity` 픽스처 2개만 남았다.

### Feature Interface 는 현재 구조에서 끊을 엣지가 없다

Splash 의 유일한 소비자는 다른 피처가 아니라 `Projects/App` 이다.
`AppReducer.swift` 가 `Splash.State`(19행), `Splash.Action`(78행), `Splash()`(155행),
`SplashView` 를 직접 조립한다. 이들은 위 규약상 Interface 에 넣지 않는 항목이므로,
`SplashInterface` 를 만들어도 App 은 여전히 구현 모듈을 의존한다.

즉 Interface 도입이 의미를 가지려면 **App 이 피처를 구현째로 조립하는 방식부터 바꿔야 한다.**
그건 이 설계의 범위를 넘는 아키텍처 변경이다.

### 그래서 Splash 파일럿은 Testing + Demo 만 만들었다

Interface 는 만들지 않았다. 지금 만들면 끊는 엣지가 없고, 나중에 App 조립 방식을
바꿀 때 다시 갈아엎어야 한다.

## 최종 결과

| 단계 | 결과 |
|---|---|
| 1. 템플릿 Demo 지원 | 완료. 기존 그래프 무변화 |
| 2. DDDDesignKitDemo | 완료. 실행·렌더링 확인, Previews 업로드 성공 |
| 3. Splash 파일럿 | 완료. Testing·Demo 생성, **Interface 보류** |
| 4. Feature 6개 확산 | 완료. Demo 만 추가. 6개 스킴 모두 빌드 성공 |
| 5. FeatureAssembly 정리 | **불필요.** Interface 를 만들지 않아 정리할 대상이 없다 |

신규 타깃은 계획 22개가 아니라 **9개**로 끝났다(Demo 8 + SplashTesting 1).
Interface 7 과 Testing 6 을 만들지 않았기 때문이다. 근거는 위 "구현 중 확인된 사실" 참고.

전체 스위트: 435개 통과 / 실패 0 / 순환 0 / segv 0.

### Joongna 그래프와의 차이

| Joongna | Attendance | |
|---|---|---|
| `JNSharedUI → JNAnimation, JNDesignKit` | `DDDSharedUI → DDDAnimation, DDDDesignKit` | 일치 |
| `JNDesignKitDemo` | `DDDDesignKitDemo` | 일치 |
| Feature × Demo | Feature × Demo (7) | 일치 |
| `JNNetwork/JNStorage + Interface` | `DDDNetwork/DDDStorage + Interface` | 일치 |
| CoreUI·CoreUtility·Logger 에 Interface 없음 | 동일 | 일치 |
| — | `DomainAssembly`·`DataAssembly` | Attendance 고유 |
| Feature × Interface (7) | 없음 | **차이** |
| Feature × Testing (7) | Splash 1개 | **차이** |

그래프 모양만 맞추려면 Interface 7개를 만들면 되지만 의존성은 바뀌지 않는다.
실제로 Joongna 처럼 되려면 `AppReducer` 가 피처를 Interface 경유로 조립하도록
바꿔야 하고, 그건 별도 설계가 필요한 아키텍처 변경이다.

## 열려 있는 위험

- **Feature 간 의존 엣지가 현재 0개다.** Interface 로 끊을 대상이 없으므로 이번 재편의
  즉각적 이득은 빌드 시간이 아니라 Demo 앱을 통한 단독 실행이다. 빌드 시간 이득을 원하면
  별도 작업(`Feature → UseCase` 디커플링, 약 30파일)이 필요하다.
  → `docs/superpowers/specs/2026-09-02-assembly-edge-alignment-design.md` 의 "이번 범위에서 제외" 절 참고.
- **Demo 앱 7개는 CI 빌드 시간을 늘린다.** Demo 를 CI 필수 빌드에서 제외할지 결정이 필요하다.
- **모듈 수 34 → 56.** `tuist generate` 시간과 워크스페이스 로딩이 느려진다.

## 검증 기준

1. `tuist generate` 성공, 순환 없음
2. Stage 스킴 테스트 타깃 수가 줄지 않는다(현재 28)
3. 전체 스위트가 재편 전과 동일한 통과 수를 유지한다
4. 각 `XDemo` 가 시뮬레이터에서 단독 실행된다
5. `XTests` 가 `XTesting` 의 더블만으로 돌고 live 구현을 링크하지 않는다

## Tuist Previews 연동

`tuist share` 로 빌드 산출물을 업로드하면 https://tuist.dev/DDD2026/attendance/previews 에서
링크로 바로 실행할 수 있다. Demo 앱과 목적이 맞는다 — 피처 하나를 리뷰어에게 링크로 넘긴다.

확인된 CLI:

```
tuist share [<apps>...] --configuration <config> --platforms ios
            --derived-data-path <path> --track <track> --json
```

적용안:

- **PR 파이프라인**: 변경된 피처의 `XDemo` 만 `--track pr` 로 공유한다.
  7개를 매번 올리면 CI 시간과 스토리지가 낭비된다.
- **develop 머지 시**: 본체 앱 `DDDAttendance` 를 `--track nightly` 로 공유한다.
- **릴리스**: `--track beta`.

CI 훅 위치는 `.github/workflows/ios-pr-coverage.yml` 의 테스트 단계 이후,
`Scripts/` 에 `share-previews.sh` 를 두고 호출한다.
`--json` 출력을 파싱해 PR 코멘트에 프리뷰 링크를 붙인다.

### 검증 기준 (추가)

6. `tuist share DDDAttendance --configuration Stage --platforms ios` 가 링크를 반환한다
7. 그 링크로 시뮬레이터에서 앱이 실행된다
8. PR 코멘트에 프리뷰 링크가 붙는다

### 선행 조건

- Previews 업로드에는 Tuist 인증이 필요하다. CI 는 `TUIST_CONFIG_TOKEN` 이 이미 설정되어
  있는지 확인해야 한다(`Tuist.swift` 의 `fullHandle: "DDD2026/attendance"`,
  `xcodeCache(upload: Environment.isCI)` 로 보아 토큰은 이미 있을 가능성이 높다).
