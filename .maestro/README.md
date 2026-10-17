# Attendance 1.1.2 로컬 QA

Maestro CLI로 지정 기기의 화면을 검사하고, 동일 UDID의 스크린샷을 저장한다.
Claude Vision은 저장된 이미지의 시각적 검토에 사용할 수 있다.
Apple Device Hub는 기기 화면을 보는 용도로 함께 사용하면 된다.

## 실행

macOS, Xcode 시뮬레이터, Python 3, Java 17 이상이 필요하다.
Java는 `JAVA_HOME`, Homebrew OpenJDK 17, `java_home -v 17+` 순서로 찾는다.

```sh
# 공식 2.11.0 배포 파일을 SHA256 검증 후 프로젝트 내부에 설치
bash .maestro/install-cli.sh

# 이미 부팅된 시뮬레이터의 UDID 확인
xcrun simctl list devices booted

# 반드시 Attendance가 설치된 시뮬레이터 UDID를 지정
python3 .maestro/run-qa.py --device <SIMULATOR_UDID> --expected-build <BUILD_NUMBER>
```

기기를 자동 선택하거나 새로 부팅하지 않는다. `io.DDD.Attendance`의 정확한 1.1.2 버전과
비어 있지 않은 빌드 번호를 확인한다. `--expected-build`는 선택 사항이며 지정하면 정확히 일치해야 한다. 설치를
확인한 뒤 해당 앱을 전면에 표시한다. 앱 종료·데이터/키체인 초기화·권한 변경·
로그인·로그아웃·탭 동작을 수행하지 않는다. 앱 자체의 실행 시 네트워크 요청은 발생할 수 있다.
다른 시뮬레이터의 실행 상태는 유지한다.

로그인이 완료된 회원/운영진 홈에서는 `--profile`을 추가해 프로필 버튼을 누르고
카드 표시, 스켈레톤·오류 영역 소멸, 버전 영역 표시를 검사할 수 있다.
이 모드는 프로필 화면에 머물러 동일 기기의 스크린샷을 남긴다.
로그인 화면에서 자동 로그인하거나 프로필 정보를 수정하지 않으며,
결과의 `scope`는 `authenticated-profile`로 구분한다.

검사 대상은 로그인/회원 홈/운영진 홈 중 하나의 표시와 홈 스켈레톤 소멸이다.
다른 상세 화면에 머물러 있으면 실패할 수 있으며 임의로 뒤로 가거나 탭하지 않는다.
이 결과는 **설치된 바이너리의 시작 화면 검사**다. 최신 소스 빌드, 전체 E2E,
1.0.9 업데이트 마이그레이션, 계정 전환, 실제 QR 카메라 검증을 대신하지 않는다.

기존 `flows/smoke_test.yaml`과 `flows/full_test.yaml`에는 초기화와 로그인 동작이 있다.
현재 세션을 보존하려면 위 실행 명령만 사용한다. 새 관찰 플로는 `qa/observe.yaml`에
분리되어 있으며 기존 워크스페이스의 `flows/*.yaml` 패턴에 포함되지 않는다.

## 결과와 Vision

매 실행의 절대 경로를 출력하며 `.maestro/artifacts/qa/run-*/`에 다음을 남긴다.

- `result.json`: 기기 ID, 앱 버전/빌드, 검사 결과, 실패 이유, 증거 경로
- `maestro.log`, `junit.xml`, `debug/`: CLI 검사 기록(실패 시 일부 파일이 없을 수 있음)
- `screen.png`: 앱 실행 후 같은 기기에서 촬영한 화면

캡처 디스플레이는 `primary`로 명시한다. iPhone Duo에서는 simctl 기본값이 다른
디스플레이를 선택해 검은 이미지가 나올 수 있다. 다른 디스플레이가 필요하면
`xcrun simctl io <UDID> enumerate`로 확인하고 `--display <이름 또는 ID>`를 전달한다.

사전 점검 실패는 앱을 실행하지 않고 종료한다. 화면 검사 실패도 종료 코드 1을 반환하며,
스크린샷 저장 성공이 검사 실패를 덮어쓰지 않는다. CLI 실행은 최대 180초로 제한한다.
산출물과 설치 도구는 Git에서 제외된다. Maestro 사용 통계 수집을 비활성화한다.
상세 진단 로그를 활성화하고 CLI 종료 후에도 이번 호출의 프로세스 그룹을 정리해
실패한 Maestro의 Xcode 자식 프로세스가 다음 검사를 방해하지 않도록 한다.

Claude Code에서 이미지 검토가 필요할 때 다음처럼 요청한다(자동 호출하지 않음).

> `<출력 경로>/result.json`과 `screen.png`를 읽고, 화면 잘림·겹침·오류 팝업·
> 남아 있는 스켈레톤을 확인해줘. 파일이나 기기를 변경하지 말고 관찰과 추측을 구분해줘.
> 화면 한 장으로 데이터 마이그레이션이나 전체 기능이 정상이라고 판정하지 마.

Vision 검토 시 해당 이미지가 모델에 전달된다. `vision_status: not_run`은 실제 검토가
없었다는 뜻이며 CLI 성공과 시각적 검토 결과는 별도로 관리한다.

## self-hosted CI 시뮬레이터 검사

`iOS 1.1.2 device QA` 워크플로는 GitHub Actions에서 수동으로 실행하거나,
같은 저장소의 브랜치에서 QA 파일을 변경한 develop 대상 PR에서 실행한다.
외부 fork PR은 이 Mac에서 실행하지 않는다. fork 저장소에서는 자신의 러너에
수동으로 실행할 수 있다.
Mac 러너의 기존 로컬 설정을 `setup-ios-runner`로 복원하고 현재 체크아웃을
Tuist로 생성한다. Duo(iOS 27.1)와 iPhone 18 Pro(iOS 27.0)를 **순서대로**
검사한다. 두 런타임과 기기 타입이 모두 Mac에 설치되어 있어야 한다.
Java 17 이상과 고정된 Maestro CLI도 필요하다.

각 기종마다 CI가 새 시뮬레이터 UUID를 발급하고 부팅한다. 그 UUID를 대상으로
Stage 앱을 새 DerivedData에 빌드해 번들 ID, 1.1.2 버전, 빌드 번호를 확인한 뒤
설치한다. `run-qa.py`가 설치된 같은 빌드의 시작 화면을 검사하며, 성공·실패 후
이번 실행에서 만든 UUID만 종료·삭제한다. 기존 Device Hub의 로그인된 Duo와
iPhone 18 Pro, 다른 시뮬레이터의 앱 데이터와 키체인은 건드리지 않는다.

새 시뮬레이터는 로그인 세션이 없으므로 CI의 통과 기준은 로그인 화면 표시 또는
회원·운영진 홈 표시와 스켈레톤 소멸이다. 자동 로그인, 실기기 WDA, Claude Vision,
1.0.9→1.1.2 업데이트와 계정 전환의 종단 간 검증은 포함되지 않는다.
CI 로그와 이미지 원본은 Mac의 `$HOME/attendance-qa-results/<repository>/<run>/<attempt>/`에
남겨 다음 matrix job의 checkout 정리에도 보존한다. `ATTENDANCE_QA_ARTIFACTS`가 없으면
로컬 실행의 기본 경로는 `.maestro/artifacts/qa/`다. GitHub artifact로 올리지 않는다.
실제 CI 통과 여부는 워크플로가
동일 저장소 PR 또는 기본 브랜치 등록 후 수동 실행 결과로 확인해야 한다.

## 선택 이유와 제한

[Maestro MCP의 다중 기기 라우팅 문제](https://github.com/mobile-dev-inc/Maestro/issues/3611)
때문에 MCP 자동 제어 대신 명시적 `--device`를 사용하는 `test` CLI를 선택했다.
시뮬레이터 실행기는 Claude Desktop 설정을 변경하거나 WDA/Appium을 설치하지 않는다.
[Maestro의 iOS 대상은 시뮬레이터](https://docs.maestro.dev/get-started/supported-platform/ios/uikit)다.
실제 iPhone 제어가 필요하면 별도로 Appium/XCUITest/WDA의 서명·기기 연결을 구성해야 한다.

## 실제 iPhone: Appium / WDA

macOS, Xcode, Node.js 24 이상(또는 Appium이 지원하는 Node 버전), 개발 인증서와
선택한 WDA 번들 ID에 유효한 프로비저닝 프로파일이 필요하다.
기기의 개발자 모드와 페어링·연결 상태를 확인한다.

```sh
# 프로젝트 내부에만 Appium 3.8.0 / XCUITest 12.18.1 설치
bash .maestro/install-wda-tools.sh

python3 .maestro/run-device-qa.py \
  --device <PHYSICAL_UDID> \
  --team <YOUR_TEAM_ID> \
  --wda-bundle-id <YOUR_PERSONAL_WDA_BUNDLE_ID> \
  --expected-build <INSTALLED_112_BUILD>
```

기기 이름·시뮬레이터 UUID를 받지 않으며 `devicectl`이 반환한 실제 UDID를 대조한다.
1.1.2 버전·빌드 확인 후 Appium을 127.0.0.1의 실행별 포트에서 시작한다.
WDA는 설치될 수 있으며 종료 후에도 기기에 남을 수 있다. 앱 자체를 설치하거나
초기화·종료하지 않고, WDA 연결 후 기존 Attendance를 전면에 표시한다.
개발자 계정의 프로비저닝 자동 갱신·기기 등록은 비활성화한다. 서명에 실패하면
프로파일을 자동 생성하지 않고 실패 결과와 `appium.log`를 남긴다.

이미 로그인했다면 현재 세션만 관찰한다. 로그아웃·계정 전환은 하지 않는다.
로그인 화면이라면 `login_status: awaiting_user_login`을 기록하며, 사용자가 직접
인증한 후 다시 실행해 홈 상태를 확인할 수 있다. 자동 인증을 수행하거나 비밀번호를
수집하지 않는다. `status: passed`는 시작 화면과 스켈레톤 검사 통과이며 전체 로그인
E2E 성공을 의미하지 않는다. 설치된 빌드는 소스 빌드와 별도로 기록한다.

결과는 `.maestro/artifacts/qa/device-*/result.json`, `appium.log`, `screen.png`에 저장한다.
실기기 이미지에는 개인 정보가 포함될 수 있으므로 로컬에만 보관하고 자동으로
Claude에 전송하지 않는다. 이미지·기기 식별자·로그·설치 도구는 커밋하지 않는다.
종료 시 이번 실행의 Appium 세션과 프로세스 그룹만 정리한다.

[XCUITest 공식 capabilities](https://appium.github.io/appium-xcuitest-driver/latest/reference/capabilities/)의
`noReset`, `autoLaunch`, `shouldTerminateApp` 설정을 명시한다.
현재 QA 범위는 1.1.2이며 이전 버전 설치·다운그레이드·실제 업데이트 검증은 수행하지 않는다.

```sh
python3 -m unittest discover -s .maestro/qa -p 'test_*.py'
bash -n .maestro/install-cli.sh
bash -n .maestro/install-wda-tools.sh
```
