# 🧪 TDD UseCase & Repository 테스트 자동화 계획서

## 📋 개요

클로드코드 서브에이전트를 활용하여 **UseCase와 Repository 테스트를 완전 자동화**하는 시스템 구축

### 🎯 목표
- 도메인 구조 자동 분석
- UseCase/Repository 테스트 자동 생성
- 실패 시 자동 수정
- PR 자동 생성 및 CI 통합

---

## 🏗️ 아키텍처 분석

### 1. UseCase 레이어 구조
```
Projects/Domain/UseCase/Sources/
├── Attendance/AttendanceUseCaseImpl.swift
├── Auth/AuthUseCaseImpl.swift
├── Profile/ProfileUseCaseImpl.swift
├── MyPage/FetchMyAttendancesUseCase.swift
├── MyPage/FetchSchedulesUseCase.swift
├── Schedule/ScheduleUseCaseImpl.swift
├── OnBoarding/OnBoardingUseCaseImpl.swift
├── QRCode/QRCodeUseCaseImpl.swift
├── SignUp/SignUpUseCaseImpl.swift
├── OAuth/UnifiedOAuthUseCase.swift
└── Manager/ (관리자 기능)
```

### 2. Repository 레이어 구조
```
Projects/Data/Repository/Sources/
├── Auth/AuthRepositoryImpl.swift
├── Attendance/AttendanceRepositoryImpl.swift
├── Profile/ProfileRepositoryImpl.swift
├── MyPage/MyPageRepositoryImpl.swift
└── 기타...
```

---

## 🧪 테스트 자동 생성 전략

### Core UseCase 테스트 (3개 도메인)

#### 1. **AuthUseCaseTest** - 인증/권한 관리
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-001 | Google 로그인 성공 | provider 검증, 토큰 저장, UserSession 업데이트 |
| TC-002 | Apple 로그인 성공 | Apple 특화 토큰 정책, oauthRefreshToken nil |
| TC-003 | 신규 사용자 로그인 | isNewUser=true, role=nil |
| TC-004 | 잘못된 토큰으로 로그인 실패 | InvalidToken Error |
| TC-005 | 네트워크 오류 로그인 실패 | Network Error |
| TC-006 | 토큰 갱신 성공 | 새로운 Access/Refresh Token |
| TC-007 | 토큰 갱신 실패 (만료) | TokenExpired Error |
| TC-008 | 로그아웃 성공 + 상태 초기화 | staffRole=nil, Keychain.clear() |
| TC-009 | 로그아웃 실패 | Server Error |
| TC-010 | 회원탈퇴 성공 + 데이터 삭제 | isSuccess=true, Keychain.clear() |
| TC-011 | 회원탈퇴 실패 (권한 없음) | Unauthorized Error |
| TC-012 | 세션 자격증명 업데이트 | updateSessionCredential 호출 |
| TC-013 | 로그인→로그아웃 전체 플로우 | End-to-End 시나리오 |
| TC-014 | 토큰 길이 경계값 검증 | 짧은/긴 토큰 처리 |
| TC-015 | 동시 로그인 요청 처리 | Concurrency 검증 |

**Mock 의존성:**
- `MockAuthRepository` (login, refresh, logout, withDraw)
- `MockKeychainManager` (save, clear, get)
- `@Shared staffRole`, `@Shared userSession`

---

#### 2. **AttendanceUseCaseTest** - 출석 관리
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-016 | 관리자 출석 통계 조회 성공 | adminAttendanceCount 응답 검증 |
| TC-017 | 출석 가능 팀 목록 조회 | fetchAttendanceTeams 권한별 팀 필터링 |
| TC-018 | 특정 일정 출석 현황 조회 | sessionAttendance 팀별/일정별 데이터 |
| TC-019 | 출석 상태 종류 조회 | fetchStatus (참석/지각/결석) |
| TC-020 | 출석 현황 수정 성공 | editAttendance 성공 플로우 |
| TC-021 | 출석 수정 실패 (권한 없음) | 일반 멤버의 타인 출석 수정 시도 |
| TC-022 | 출석 수정 실패 (잘못된 데이터) | 유효하지 않은 scheduleId, teamId |
| TC-023 | 출석 통계 계산 검증 | 참석/지각/결석 수 계산 로직 |
| TC-024 | 팀별 출석 데이터 필터링 | iOS/Android/Web 팀 분리 |
| TC-025 | 출석 상태 변경 플로우 | 참석→지각, 참석→결석 변경 |
| TC-026 | 출석 데이터 일관성 검증 | scheduleId, userId 매칭 |
| TC-027 | 출석 수정 권한 검증 | Manager vs Member 권한 차이 |
| TC-028 | 출석 기록 히스토리 검증 | 수정 전후 상태 비교 |

**Mock 의존성:**
- `MockAttendanceRepository` (adminAttendanceCount, sessionAttendance, editAttendance 등)
- `@Shared staffRole` (Manager/Member 권한 검증)

---

#### 3. **ProfileUseCaseTest** - 프로필 관리
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-029 | 프로필 조회 성공 | getProfile, staffRole 동기화 |
| TC-030 | UserSession 동기화 검증 | userID, name, generation 등 업데이트 |
| TC-031 | 매니저 프로필 조회 | Manager 권한 정보 포함 |
| TC-032 | 멤버 프로필 조회 | Member 기본 정보만 |
| TC-033 | 프로필 편집 성공 | editProfile 기본 정보 수정 |
| TC-034 | 매니저 권한 편집 | managerRoles 포함 편집 |
| TC-035 | 멤버 권한 편집 제한 | managerRoles 제외 편집 |
| TC-036 | 팀/직무 변경 검증 | selectTeam, selectPart 업데이트 |
| TC-037 | 기수 정보 검증 | generation 형식 및 유효성 |
| TC-038 | 초대 코드 검증 | Manager/Member 초대 코드 차이 |
| TC-039 | 프로필 권한 승급 시나리오 | Member → Manager 승급 |
| TC-040 | 프로필 데이터 일관성 | 권한-팀-직무 매칭 검증 |

**Mock 의존성:**
- `MockProfileRepository` (getProfile, editProfile)
- `@Shared staffRole`, `@Shared userSession`

---

### Repository 테스트 전략

#### 1. **AuthRepositoryTest** - 인증 API 통신
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-041 | 로그인 API 호출 성공 | POST /auth/login 응답 검증 |
| TC-042 | 로그인 API 실패 (401) | 인증 실패 에러 처리 |
| TC-043 | 토큰 갱신 API 호출 | POST /auth/refresh 헤더/바디 검증 |
| TC-044 | 로그아웃 API 호출 | DELETE /auth/logout Bearer 토큰 |
| TC-045 | 회원탈퇴 API 호출 | DELETE /user 토큰 검증 |
| TC-046 | API 응답 DTO 매핑 | LoginResponse → LoginEntity |
| TC-047 | 네트워크 에러 처리 | Timeout, No Connection |
| TC-048 | API 인증 헤더 검증 | Authorization Bearer 형식 |

**Mock 의존성:**
- `MockNetworkService` (Moya Provider)
- `MockDTO` 응답 객체들

#### 2. **AttendanceRepositoryTest** - 출석 API 통신
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-049 | 출석 통계 조회 API | GET /attendance/admin/count |
| TC-050 | 팀 목록 조회 API | GET /attendance/teams |
| TC-051 | 출석 현황 조회 API | GET /attendance/session |
| TC-052 | 출석 수정 API | PUT /attendance/edit |
| TC-053 | API 쿼리 파라미터 검증 | scheduleId, teamId 전달 |
| TC-054 | API 응답 에러 처리 | 400, 403, 500 에러 |
| TC-055 | DTO 매핑 검증 | AttendanceResponse → Attendance |

#### 3. **ProfileRepositoryTest** - 프로필 API 통신
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-056 | 프로필 조회 API | GET /user/profile |
| TC-057 | 프로필 편집 API | PUT /user/profile |
| TC-058 | API 요청 바디 검증 | EditProfileRequest 직렬화 |
| TC-059 | DTO 매핑 검증 | ProfileResponse → ProfileEntity |

---

## 🤖 자동화 도구 구현 계획

### 1. TuistTool.swift 확장

```swift
// 새로운 명령어 추가
enum Command: String, CaseIterable {
    case tddauto = "tdd-auto"
    case usecasetest = "usecase-test"    // ← 새로 추가
    case repositorytest = "repository-test" // ← 새로 추가
    case fulltest = "full-test"          // ← 새로 추가
}
```

### 2. 자동 생성 함수들

```swift
// UseCase 테스트 자동 생성
func generateUseCaseTestsWithAI() {
    let domains = ["Auth", "Attendance", "Profile"]
    for domain in domains {
        print("🧪 \(domain) UseCase 테스트 자동 생성 중...")

        // 1. 클로드코드 서브에이전트로 UseCase 분석
        let usecaseStructure = analyzeUseCaseWithAgent(domain)

        // 2. AI가 테스트 코드 생성
        let testContent = generateUseCaseTestWithAgent(
            domain: domain,
            structure: usecaseStructure
        )

        // 3. 테스트 파일 생성
        createUseCaseTestFile(domain: domain, content: testContent)

        // 4. 컴파일 검증 및 실패 시 수정
        validateAndFixUseCaseTest(domain: domain)
    }
}

// Repository 테스트 자동 생성
func generateRepositoryTestsWithAI() {
    let domains = ["Auth", "Attendance", "Profile"]
    for domain in domains {
        print("🔌 \(domain) Repository 테스트 자동 생성 중...")

        // 1. Repository 구조 분석
        let repositoryStructure = analyzeRepositoryWithAgent(domain)

        // 2. API 스펙 기반 테스트 생성
        let testContent = generateRepositoryTestWithAgent(
            domain: domain,
            structure: repositoryStructure
        )

        // 3. Mock Network Service 포함 테스트 생성
        createRepositoryTestFile(domain: domain, content: testContent)

        // 4. API 호출 검증 테스트 추가
        addMockNetworkTests(domain: domain)
    }
}
```

### 3. 클로드코드 서브에이전트 연동

```swift
// 서브에이전트를 활용한 도메인 분석
func analyzeUseCaseWithAgent(_ domain: String) -> String {
    return """
    클로드코드 서브에이전트야, \(domain) 도메인의 UseCase를 분석해줘.

    다음을 포함해서 분석해줘:
    1. public func 메서드들의 시그니처
    2. @Dependency로 주입되는 의존성들
    3. @Shared로 관리되는 상태들
    4. async/await 비동기 처리
    5. 에러 처리 패턴
    6. 비즈니스 로직 플로우

    분석 결과를 테스트 케이스 생성에 활용할 수 있도록 구조화된 형태로 반환해줘.
    """
}

func generateUseCaseTestWithAgent(domain: String, structure: String) -> String {
    return """
    클로드코드 서브에이전트야, \(domain) UseCase 테스트를 생성해줘.

    요구사항:
    1. Swift Testing (@Test, @Suite) 프레임워크 사용
    2. @MainActor 비동기 테스트
    3. Given-When-Then 구조
    4. TC-001부터 순차적 번호 할당
    5. Mock Repository/Keychain/UserSession 활용
    6. 성공/실패 케이스 모두 포함
    7. 경계값 테스트
    8. 동시성 테스트
    9. withDependencies 사용한 DI 테스트
    10. #expect로 상세 검증

    도메인 구조 정보:
    \(structure)

    완전한 테스트 파일을 Swift 코드로 생성해줘.
    """
}
```

### 4. 자동 PR 생성 및 CI 통합

```swift
// 완전 자동화 플로우
func runFullTDDAutomation() {
    print("🚀 완전 TDD 자동화 시작...")

    // 1. UseCase 테스트 생성
    generateUseCaseTestsWithAI()

    // 2. Repository 테스트 생성
    generateRepositoryTestsWithAI()

    // 3. 테스트 실행 및 검증
    runAllTestsAndValidate()

    // 4. 실패한 테스트 자동 수정
    fixFailedTestsWithAI()

    // 5. 각 도메인별 PR 생성
    createDomainSpecificPRs()

    // 6. CI 파이프라인 트리거
    triggerCIPipeline()

    print("✅ 완전 자동화 완료!")
}
```

---

## 🎯 실행 명령어

```bash
# 전체 자동화 (UseCase + Repository + PR 생성)
./make full-test

# UseCase 테스트만 생성
./make usecase-test

# Repository 테스트만 생성
./make repository-test

# 기존 Entity 테스트
./make tdd-auto
```

---

## 📊 예상 산출물

### 생성될 테스트 파일들
```
Projects/Domain/UseCase/UseCaseTests/Sources/
├── Auth/AuthUseCaseTest.swift (15개 TC)
├── Attendance/AttendanceUseCaseTest.swift (13개 TC)
└── Profile/ProfileUseCaseTest.swift (12개 TC)

Projects/Data/Repository/RepositoryTests/Sources/
├── Auth/AuthRepositoryTest.swift (8개 TC)
├── Attendance/AttendanceRepositoryTest.swift (7개 TC)
└── Profile/ProfileRepositoryTest.swift (4개 TC)
```

### 총 테스트 케이스 수
- **UseCase 테스트**: 40개 TC
- **Repository 테스트**: 19개 TC
- **Entity 테스트**: 기존 생성됨
- **전체**: ~60개 TC

---

## ✅ 품질 보증

### 자동 검증 항목
1. **컴파일 성공**: Swift 문법 검증
2. **테스트 실행**: 모든 TC 통과
3. **코드 커버리지**: 90% 이상 목표
4. **Mock 검증**: 의존성 완전 분리
5. **CI/CD 통합**: GitHub Actions 자동 실행

### 실패 시 자동 수정
- 컴파일 오류 → AI 자동 수정
- 테스트 실패 → 원인 분석 후 수정
- Mock 오류 → 의존성 재정의

---

## 🔄 지속적 개선

### Phase 1: Core 도메인 (현재)
- Auth, Attendance, Profile

### Phase 2: 확장 도메인 (추가 도메인 테스트 계획)

#### 4. **ScheduleUseCaseTest** - 일정 관리
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-150 | 일정 생성 성공 | createSchedule 정상 플로우 |
| TC-151 | 일정 생성 실패 (권한 없음) | Member의 일정 생성 시도 |
| TC-152 | 일정 생성 실패 (잘못된 날짜) | 과거 날짜, 시간 충돌 검증 |
| TC-153 | 팀별 일정 목록 조회 | fetchSchedules 팀 필터링 |
| TC-154 | 일정 수정/삭제 권한 검증 | Manager vs Member 권한 |
| TC-155 | 일정 상태 변경 플로우 | 예정→진행→완료 |

#### 5. **MyPageUseCaseTest** - 마이페이지
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-160 | 내 출석 기록 조회 | fetchMyAttendances 개인 데이터 |
| TC-161 | 내 일정 목록 조회 | fetchMySchedules 개인별 필터링 |
| TC-162 | 출석 통계 계산 | 개인 출석률, 지각 횟수 |
| TC-163 | 알림 설정 관리 | notification preferences |
| TC-164 | 개인정보 수정 | profile update |

#### 6. **QRCodeUseCaseTest** - QR 코드 스캔
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-170 | QR 코드 스캔 성공 | 유효한 QR 코드 처리 |
| TC-171 | QR 코드 스캔 실패 | 잘못된/만료된 QR 코드 |
| TC-172 | 출석 체크 연동 | QR → 출석 등록 플로우 |
| TC-173 | 중복 스캔 방지 | 동일 세션 중복 처리 |

#### 7. **OnBoardingUseCaseTest** - 온보딩
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-180 | 온보딩 단계 진행 | step-by-step navigation |
| TC-181 | 권한 요청 처리 | camera, notification 권한 |
| TC-182 | 팀 선택 및 등록 | team assignment |
| TC-183 | 온보딩 완료 처리 | user setup completion |

#### 8. **ManagerUseCaseTest** - 관리자 기능
| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-190 | 전체 출석 통계 관리 | 관리자 대시보드 데이터 |
| TC-191 | 팀원 관리 | 팀원 추가/제거/권한 변경 |
| TC-192 | 일정 일괄 관리 | 다중 일정 생성/수정/삭제 |
| TC-193 | 시스템 설정 관리 | 앱 전역 설정 변경 |

**Mock 의존성 (확장 도메인):**
- `MockScheduleRepository`, `MockMyPageRepository`
- `MockQRCodeService`, `MockOnBoardingRepository`
- `MockManagerRepository`, `@Shared managerPermissions`

### Phase 3: 고급 테스트
- Integration 테스트 (도메인 간 연동)
- Performance 테스트 (대용량 데이터 처리)
- UI 테스트 (TCA Feature 통합)
- End-to-End 테스트 (전체 사용자 플로우)

---

## 📝 마무리

이 계획서를 바탕으로 **완전 자동화된 TDD 시스템**을 구축하여:

1. ✅ **개발자 생산성 향상** - 수동 테스트 작성 시간 단축
2. ✅ **코드 품질 보증** - 체계적인 테스트 커버리지
3. ✅ **CI/CD 자동화** - 지속적 통합 및 배포
4. ✅ **도메인 확장성** - 새로운 도메인 추가 시 자동 테스트 생성

**🎯 최종 목표: `./make full-test` 한 번으로 모든 도메인의 UseCase/Repository 테스트 자동 생성 및 PR 배포**