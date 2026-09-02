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
