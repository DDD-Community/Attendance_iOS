# DDD 출석 iOS

<div align="center">


<img width="150" alt="DDD Logo" src="https://github.com/user-attachments/assets/667db68b-d600-4e2d-a50f-f517de7b30fa">

**DDD IT 동아리를 위한 출석 관리 시스템**

![Platform](https://img.shields.io/badge/Platform-iOS-orange.svg)
![Language](https://img.shields.io/badge/Language-Swift-FA7343.svg?logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-17.0+-34C759.svg)
![Xcode](https://img.shields.io/badge/Xcode-16.0+-007ACC.svg)
![TCA](https://img.shields.io/badge/Architecture-TCA-purple.svg)
![Tuist](https://img.shields.io/badge/Modularization-Tuist-blue.svg)
![Fastlane](https://img.shields.io/badge/fastlane-00F200.svg?logo=fastlane&logoColor=white)

[📱 App Store](https://apps.apple.com/kr/app/ddd/id6736766383) | [🎯 Features](#-주요-기능) | [🏗 Architecture](#-프로젝트-아키텍처) | [🚀 Quick Start](#-빠른-시작)

---

</div>

## 📖 프로젝트 소개

**DDD 출석**은 DDD IT 동아리의 출석 관리를 효율적으로 도와주는 iOS 애플리케이션입니다.
간단하고 직관적한 인터페이스로 동아리원들의 출석 현황을 관리하고, 동아리 활동을 체계화할 수 있도록 지원합니다.

> 💡 **우리는 왜 이 앱을 만들었을까요?**
> DDD IT 동아리의 출석 관리를 위한 번거로운 과정을 줄이고,
> 개발자들이 학습과 네트워킹에 더 집중할 수 있는 환경을 만들고자 합니다.

## 🛠 Setup

### AI 도구 연동

프로젝트 규칙은 AGENTS.md에 정의되어 있습니다. Claude Code 사용 시 심볼릭 링크를 연결하세요.

```bash
ln -s AGENTS.md CLAUDE.md
```

### 📱 스크린샷

<div align="center">

| 메인 화면 | 로그인 | 출석 관리 |
|:---:|:---:|:---:|
| <img width="200" src="fastlane/screenshots/ko/0_APP_IPHONE_65_0.png"> | <img width="200" src="fastlane/screenshots/ko/1_APP_IPHONE_65_1.png"> | <img width="200" src="fastlane/screenshots/ko/2_APP_IPHONE_65_2.png"> |

| 출석 멤버 | 프로필 | 일정 |
|:---:|:---:|:---:|
| <img width="200" src="fastlane/screenshots/ko/3_APP_IPHONE_65_3.png"> | <img width="200" src="fastlane/screenshots/ko/4_APP_IPHONE_65_4.png"> | <img width="200" src="fastlane/screenshots/ko/5_APP_IPHONE_65_5.png"> |

</div>

## ✨ 주요 기능

### 🔐 간편한 인증
- **Google OAuth 2.0**: 간단한 구글 계정 로그인
- **자동 로그인 유지**: 재실행 시 자동 인증 상태 유지
- **보안 강화**: OAuth 2.0 기반 안전한 인증 시스템

### 📊 출석 관리
- **실시간 출석 체크**: 빠르고 정확한 출석 확인
- **출석 상태 관리**: 출석, 지각, 결석, 대기 상태 구분
- **출석 이력 조회**: 개인별 출석 현황 및 통계
- **출석률 통계**: 시각적 통계 정보 제공

### 👥 멤버 관리
- **스터디 멤버 목록**: 전체 참가자 현황 확인
- **멤버 상태 조회**: 각 멤버의 출석 패턴 분석
- **관리자 권한**: 스터디 운영진을 위한 관리 기능

### 📱 사용자 경험
- **직관적 UI/UX**: 간단하고 명확한 인터페이스
- **실시간 동기화**: 서버와의 실시간 데이터 동기화
- **오프라인 지원**: 네트워크 없이도 기본 기능 사용 가능
- **다크 모드**: 시스템 설정에 따른 다크/라이트 모드 지원

## 🏗 프로젝트 아키텍처

### 🎯 Clean Architecture with Tuist

```
DDD-Attendance-iOS/
├── 📱 Projects/
│   ├── App/                     # 메인 애플리케이션 타겟
│   │   ├── Sources/
│   │   │   ├── Application/     # AppDelegate, SceneDelegate
│   │   │   ├── Di/             # Dependency Injection
│   │   │   ├── Reducer/        # TCA Root Reducer
│   │   │   └── View/           # Root Views
│   │   ├── Resources/          # Assets, Fonts, Localizations
│   │   └── Tests/              # App 레벨 테스트
│   │
│   ├── Presentation/           # 🎨 UI Layer
│   │   ├── Auth/               # 로그인/인증 화면
│   │   ├── Splash/             # 스플래시 화면
│   │   ├── OnBoarding/         # 온보딩 화면
│   │   ├── Management/         # 출석 관리 화면
│   │   ├── Member/             # 멤버 관리 화면
│   │   ├── Profile/            # 프로필 화면
│   │   ├── Web/                # 웹뷰 화면
│   │   └── Presentation/       # 공통 프레젠테이션 유틸
│   │
│   ├── Domain/                 # 🔥 Business Logic Layer
│   │   ├── Entity/             # 도메인 엔티티
│   │   ├── UseCase/            # 비즈니스 로직 구현
│   │   └── RepositoryInterface/ # Repository 프로토콜
│   │
│   ├── Data/                   # 📡 Data Layer
│   │   ├── Repository/         # Repository 구현체
│   │   ├── DataSource/         # 로컬/원격 데이터소스
│   │   └── Model/              # DTO, Response Models
│   │
│   ├── Network/                # 🌐 Network Layer
│   │   ├── Foundation/         # 네트워크 기반 설정
│   │   ├── Service/            # API 서비스 구현
│   │   └── Configuration/      # 네트워크 설정
│   │
│   └── Shared/                 # 🔧 Shared Layer
│       ├── DesignSystem/       # 디자인 시스템
│       ├── Utility/            # 공통 유틸리티
│       └── Extension/          # Swift Extensions
│
└── 🔧 Tuist/                   # 프로젝트 설정
    ├── Package.swift
    ├── ProjectDescriptionHelpers/
    └── Dependencies.swift
```

### 🏛️ Clean Architecture Pattern

```mermaid
graph TD
    A[🎨 Presentation Layer] --> B[🔥 Domain Layer]
    B --> C[📡 Data Layer]
    D[🌐 Network Layer] --> C
    E[🔧 Shared Layer] --> A
    E --> B
    E --> C

    A -.-> F[SwiftUI Views]
    A -.-> G[TCA Reducers]
    B -.-> H[Use Cases]
    B -.-> I[Entities]
    C -.-> J[Repositories]
    C -.-> K[API Services]
```

### 📊 의존성 그래프 (Tuist Graph)

<div align="center">

![Dependency Graph](graph.png)

</div>

*프로젝트 모듈 간 의존성 관계도 (자동 생성)*

#### 🕸️ TuistSpider 확장 뷰

레이어별로 묶어 보거나(Grouped) 모든 모듈을 펼쳐 본(Expanded) 시각화입니다. (TuistSpider 결과)

<div align="center">

| Grouped | Expanded |
|:---:|:---:|
| <img src="docs/graphs/DDDAttendance-grouped-DDDAttendance.png" width="420"> | <img src="docs/graphs/DDDAttendance-expanded-DDDAttendance.png" width="420"> |

</div>

### 🔄 의존성 방향 원칙

```
Presentation → Domain (UseCase Protocol)
       ↓
Domain/UseCase → Domain (Repository Protocol)
       ↓
Data/Repository → Domain (Entity + Repository Protocol)
       ↓
Network/Service → Data (API 통신)
```

**핵심 설계 원칙:**
- ✅ **Presentation**은 Domain의 UseCase만 의존
- ✅ **Domain**은 외부 계층에 의존하지 않는 순수 비즈니스 로직
- ✅ **Data**는 Domain의 Entity와 Repository Protocol을 구현
- ✅ 모든 데이터 흐름은 **Domain을 중심**으로 진행

## 📚 개발 가이드 문서

프로젝트의 상세한 개발 가이드라인은 `docs/` 폴더의 문서들을 참고하세요:

### 🏗️ 아키텍처 & 패턴
- **[TCA 패턴 가이드](./docs/tca-patterns.md)** - TCA 기본 구조, Extension 패턴, Action 처리
- **[SwiftUI 스타일 가이드](./docs/swiftui-patterns.md)** - View 구조화, Extension 패턴, @ViewBuilder 활용
- **[의존성 주입 (DI)](./docs/dependency-injection.md)** - WeaveDI 3.4.1 패턴, AppDIManager
- **[TCAFlow 네비게이션](./docs/tcaflow-navigation.md)** - @FlowCoordinator, 화면 전환, 딥 링크

### 🎨 UI & UX 시스템
- **[팝업 & 모달 시스템](./docs/popup-modal-system.md)** - CustomAlert, Toast, Modal 구현
- **[Swift 코딩 규칙](./docs/swift-coding-rules.md)** - Swift 스타일, 에러 처리, 테스트 패턴

### 🚀 성능 & 최적화
- **[iOS 성능 최적화](./docs/ios-performance-optimization.md)** - 서브에이전트 호출, 빌드 오류 해결

### 🛠️ 개발 환경 & 협업
- **[Git 워크플로우](./docs/git-workflow.md)** - 브랜치 전략, PR 규칙, 코드 리뷰
- **[개발 환경 설정](./docs/development-environment.md)** - Make 명령어, Xcode 설정, Tuist

> 💡 **참고**: 이 가이드 문서들은 AI 에이전트들도 참조하여 프로젝트의 일관성 있는 코드 품질을 유지합니다.

## 🛠 기술 스택

### Core Technologies
- **🎯 Architecture**: The Composable Architecture (TCA) 1.25.5
- **📦 Modularization**: Tuist 4.x (Micro Feature Architecture)
- **💉 Dependency Injection**: WeaveDI 3.4.0
- **🔀 Navigation**: TCAFlow 1.1.0 (커스텀 라이브러리)
- **⚡ Concurrency**: Swift Concurrency (async/await)

### 📚 주요 라이브러리

#### 🎯 아키텍처 & 상태 관리
- **[ComposableArchitecture](https://github.com/pointfreeco/swift-composable-architecture)** 1.25.5 - 단방향 데이터 플로우 및 상태 관리
- **[TCAFlow](https://github.com/Roy-wonji/TCAFlow.git)** 1.1.0 ⭐️ - TCA 기반 화면 전환 및 네비게이션 (커스텀)
- **[WeaveDI](https://github.com/Roy-wonji/WeaveDI.git)** 3.4.0 ⭐️ - 의존성 주입 컨테이너 (커스텀 포크)

#### 🔐 인증 & 보안
- **[GoogleSignIn-iOS](https://github.com/google/GoogleSignIn-iOS)** 9.2.0 - Google OAuth 2.0 인증
- **[AppAuth-iOS](https://github.com/openid/AppAuth-iOS.git)** 2.1.0 - OAuth 2.0 및 OpenID Connect 클라이언트

#### 🌐 네트워킹
- **DDDNetwork** - Alamofire 기반 요청·인증·토큰 재발급을 제공하는 자체 네트워크 모듈

#### 🎨 UI & UX
- **[SwiftUIX](https://github.com/SwiftUIX/SwiftUIX.git)** 0.2.3 - SwiftUI 확장 컴포넌트
- **[SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI.git)** 2.0.0 - 비동기 이미지 로딩 및 캐싱

#### 🔥 백엔드 서비스
- **[Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk)** 12.7.0 - Analytics, Crashlytics, Remote Config

### 🛠 개발 도구 & 유틸리티

#### 📊 로깅 & 디버깅
- **DDDCoreLogger**: os.Logger 기반 자체 로거 (값은 `.private` 로 기록)
- **IssueReporting**: 개발 단계 이슈 추적
- **XCTestDynamicOverlay**: 테스트 환경 오버레이

#### ⚡ 성능 & 동시성
- **Clocks**: 시간 관련 유틸리티
- **ConcurrencyExtras**: Swift Concurrency 확장
- **Swift 6.0**: 최신 Swift 언어 기능

#### 🔧 빌드 & 배포
- **Tuist**: 프로젝트 생성 및 의존성 관리
- **Swift Package Manager (SPM)**: 패키지 의존성 관리
- **fastlane**: 자동화된 빌드 및 배포

### 📱 지원 환경
- **💻 Xcode**: 16.0 이상
- **📱 iOS**: 17.0 이상
- **⚡ Swift**: 6.0 이상
- **🔧 Tuist**: 4.x 이상

## 🚀 빠른 시작

### ✅ 필수 요구사항

- **💻 Xcode**: 16.0 이상
- **📱 iOS**: 17.0 이상
- **⚡ Swift**: 6.0 이상
- **🔧 Tuist**: 4.x 이상

### 🛠 설치 및 실행

#### 1️⃣ 저장소 클론
```bash
git clone https://github.com/DDD-Community/Attendance_iOS.git
cd Attendance_iOS
```

#### 2️⃣ Tuist 설치
```bash
curl -Ls https://install.tuist.io | bash
```

#### 3️⃣ 프로젝트 빌드 및 생성
```bash
# 전체 워크플로우 (권장)
./make build      # clean → install → generate

# 또는 단계별 실행
./make clean      # 기존 파일 정리
./make install    # 의존성 설치
./make generate   # 프로젝트 생성
```

#### 4️⃣ Xcode에서 실행
```bash
open DDDAttendance.xcworkspace
```

### ⚙️ 환경 설정

프로젝트 실행을 위해 다음 설정이 필요합니다:

```swift
// Config 파일에서 설정 (Stage.xcconfig, Prod.xcconfig)
BASE_URL = api.dddstudy.kr/
GOOGLE_CLIENT_ID = YOUR_GOOGLE_CLIENT_ID
GOOGLE_IOS_CLIENT_ID = YOUR_GOOGLE_IOS_CLIENT_ID
REVERSED_CLIENT_ID = YOUR_REVERSED_CLIENT_ID
```

## 🛠️ 주요 명령어

### 🔄 기본 워크플로우
```bash
./make build      # 전체 빌드 프로세스 (권장)
./make generate   # 프로젝트 생성만
./make clean      # 빌드 아티팩트 정리
./make install    # 의존성 설치
```

### 🚨 문제 해결
```bash
tuist clean       # Tuist 캐시 정리
./make clean      # 모든 빌드 파일 정리
```

### 🔍 코드 품질 관리
```bash
tuist graph       # 의존성 그래프 생성
tuist test        # 전체 테스트 실행
```

### 📱 fastlane 자동화
```bash
fastlane ios beta               # TestFlight 배포
fastlane ios release            # App Store 배포
fastlane ios screenshots        # 스크린샷 자동 생성
fastlane ios build_for_testing  # 테스트 빌드
```

**fastlane 주요 기능:**
- 자동화된 빌드 및 배포
- App Store Connect 관리
- 인증서 및 프로필 관리
- 스크린샷 자동 생성

## 📋 사용법

### 1️⃣ 초기 설정
1. **앱 다운로드 및 설치**
2. **Google 계정으로 로그인**
3. **권한 설정** (푸시 알림 등)

### 2️⃣ 출석 체크
1. **출석 탭**에서 현재 스터디 세션 확인
2. **출석 체크** 버튼 터치
3. **출석 상태** 자동 업데이트 (출석/지각/결석/대기)

### 3️⃣ 출석 현황 조회
1. **통계 탭**에서 개인 출석률 확인
2. **달력 뷰**로 월별 출석 패턴 확인
3. **상세 이력** 조회 가능

### 4️⃣ 프로필 관리
1. **프로필 탭**에서 개인 정보 확인
2. **설정** 메뉴에서 앱 환경 설정
3. **로그아웃** 및 계정 관리

## 📄 라이선스

이 프로젝트는 **MIT 라이선스** 하에 배포됩니다.
자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

## 👥 팀 & 크레딧

### 💻 개발팀
- **iOS Lead Developer**: 서원지 ([@Roy-wonji](https://github.com/Roy-wonji))
- **iOS Developer**: 홍은표 ([@honghoker](https://github.com/honghoker))

### 🛠 기술 스택
- **iOS**: 
  ![Swift](https://img.shields.io/badge/swift-F05138?style=for-the-badge&logo=swift&logoColor=white)
  ![Xcode](https://img.shields.io/badge/xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white)
  ![Fastlane](https://img.shields.io/badge/fastlane-00F200?style=for-the-badge&logo=fastlane&logoColor=white)

- **Server**: 
  ![AWS EC2](https://img.shields.io/badge/amazonec2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)
  ![AWS](https://img.shields.io/badge/amazonaws-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
  ![Swagger](https://img.shields.io/badge/swagger-85EA2D?style=for-the-badge&logo=swagger&logoColor=white)

- **Design**: 
  ![Figma](https://img.shields.io/badge/figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white)

- **VCS**: 
  ![Git](https://img.shields.io/badge/git-F05032?style=for-the-badge&logo=git&logoColor=white)
  ![GitHub](https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white)

## 🐈‍⬛ Git 브랜칭 전략

### 1️⃣ Git Branching Strategy

- **Main Branch**: 프로덕션 배포용
- **Develop Branch**: 개발 통합 브랜치  
- **Feature Branch**: 기능별 개발 브랜치

### 📋 워크플로우
1. **Develop** 브랜치에서 **Feature** 브랜치 생성
2. **Feature** 브랜치에서 개발 진행
3. **Feature** → **Develop** Pull Request
4. 코드 리뷰 및 충돌 해결 후 머지
5. **Develop** → **Main** 배포용 Pull Request

## 📞 문의 및 지원

- 📧 **이메일**: suhwj81@gmail.com
- 🐛 **버그 신고**: [Issues](https://github.com/DDD-Community/Attendance_iOS/issues)
- 💡 **기능 제안**: [Discussions](https://github.com/DDD-Community/Attendance_iOS/discussions)
- 📱 **App Store**: [DDD 출석 다운로드](https://apps.apple.com/kr/app/ddd/id6736766383)

---

<div align="center">

**Made with ❤️ by DDD Team**

[![Star this repo](https://img.shields.io/github/stars/Roy-wonji/DDD-Attendance-iOS?style=social)](https://github.com/DDD-Community/Attendance_iOS)

</div>
