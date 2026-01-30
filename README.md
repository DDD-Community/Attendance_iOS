# DDD 출석앱
About DDD 출석 앱


## Tuist Usage
1. Install tuist
 
```swift
curl -Ls https://install.tuist.io | bash 
```
2. Generate project

```swift
tuist clean // optional
make install // optional
make generate
```

## 🧪 TDD 자동화

AI 기반 자동화된 TDD(Test-Driven Development) 워크플로우를 제공합니다.

### 🚀 빠른 시작

```bash
# 모든 도메인에 대해 테스트 생성 및 실행
make tdd-all

# 특정 도메인만 테스트
make tdd-attendance      # Attendance 도메인
make tdd-auth           # Auth 도메인
make tdd-profile        # Profile 도메인

# 커스텀 도메인 지정
make tdd-domain DOMAIN=MyPage
```

### 📋 지원 기능

- **🔍 도메인 분석**: 자동으로 프로젝트 구조 파악
- **📝 테스트 생성**: Entity, UseCase, Repository 레이어별 테스트 자동 생성
- **🔄 자동 실행**: xcodebuild test로 테스트 실행
- **🛠️ 자동 수정**: 실패 시 AI가 자동으로 수정 시도
- **🚀 PR 자동화**: 모든 테스트 통과 시 자동으로 Pull Request 생성

### 🏗️ 지원 도메인

- `Attendance` - 출석 관리
- `Auth` - 사용자 인증
- `Profile` - 프로필 관리
- `Schedule` - 스케줄 관리
- `OnBoarding` - 온보딩 프로세스
- `QRCode` - QR코드 처리
- `MyPage` - 마이페이지
- `SignUp` - 회원가입
- `OAuth` - Apple/Google 로그인

### 🧪 테스트 프레임워크

- **Swift Testing** - 최신 Swift 테스트 프레임워크 (`@Test`, `@Suite`)
- **XCTest** - CI/CD 호환성을 위한 전통적 테스트
- **TCA TestStore** - Composable Architecture 상태 테스트
- **Mock Providers** - Moya 기반 API 모킹

### 📊 예시 결과

```bash
$ make tdd-attendance

🚀 Starting TDD automation...
✅ Project root confirmed
🔧 Generating Tuist workspace...
📝 Creating test files...
  - AttendanceEntityTest.swift
  - AttendanceUseCaseTest.swift
  - AttendanceRepositoryTest.swift
🧪 Running tests...
✅ All tests passed!
🚀 Creating Pull Request...
🎉 Pull Request created successfully!
```

### 🛠️ 고급 옵션

```bash
# PR 제목 커스텀
./scripts/tdd-automation.sh --pr-title "Add Auth layer tests"

# 기존 테스트 파일 건너뛰기
./scripts/tdd-automation.sh --skip-existing

# 자동 수정 재시도 횟수 설정
./scripts/tdd-automation.sh --retries 5

# 도움말
./scripts/tdd-automation.sh --help
```

### 🔧 개발자 도구

```bash
# 테스트만 실행
make test              # 조용한 모드
make test-verbose      # 상세 로그

# 프로젝트 상태 확인
make status           # Git 상태, 테스트 파일 개수 등
make debug-domains    # 현재 도메인 구조 확인

# 코드 품질
make format           # SwiftFormat (설치 필요)
make lint            # SwiftLint (설치 필요)
```

## 기술 스택 
- iOS  
  <img src="https://img.shields.io/badge/fastlane-00F200?style=for-the-badge&logo=fastlane&logoColor=white">
  <img src="https://img.shields.io/badge/swift-F05138?style=for-the-badge&logo=swift&logoColor=white">
  <img src="https://img.shields.io/badge/xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white"> 
  
  - Server  
  <img src="https://img.shields.io/badge/amazonec2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white">
  <img src="https://img.shields.io/badge/amazonaws-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white">
  <img src="https://img.shields.io/badge/swagger-85EA2D?style=for-the-badge&logo=swagger&logoColor=white">
   
  
  - Design  
  <img src="https://img.shields.io/badge/figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white">
  
  - VCS  
  <img src="https://img.shields.io/badge/git-F05032?style=for-the-badge&logo=git&logoColor=white"> 
  <img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white"> 
  
## 🐈‍⬛ Git

### 1️⃣ Git branching Strategy

- Origin(main branch)
- Origin(dev branch)
- Local(feature branch)

- Branch
- Main
- Dev
- Feature
- Fix

- 방법
- 1. Pull the **Dev** branch of the Origin
- 2. Make a **Feature** branch in the Local area
- 3. Developed by **Feature** branch
- 4. Push the **Feature** from Local to Origin
- 5. Send a pull request from the origin's **Feature** to the Origin's **Dev**
- 6. In Origin **Dev**, resolve conflict and merge
- 7. Fetch and rebase Origin **Dev** from Local **Dev**


<br>

## 🧑🏻‍💻 팀원 소개


### Developer

#### iOS
- [서원지](https://github.com/Roy-wonji)</br>
- [홍은표](https://github.com/honghoker)

