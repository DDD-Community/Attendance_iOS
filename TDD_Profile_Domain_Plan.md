# 👤 Profile 도메인 TDD 자동화 계획서

## 📋 도메인 개요
**Profile 도메인**은 사용자 프로필, 권한 관리, 팀/직무/기수 정보를 담당하는 사용자 관리 도메인입니다.

---

## 🏗️ 아키텍처 구조

### UseCase 레이어
**파일**: `Projects/Domain/UseCase/Sources/Profile/ProfileUseCaseImpl.swift`

**주요 메서드**:
- `getProfile()` → 프로필 조회 + staffRole 동기화
- `editUser(userSession: UserSession)` → 사용자 정보 수정
- `editProfile(input: EditProfileInput)` → 프로필 편집 (내부)

**의존성**:
- `@Dependency(\.profileRepository)` - API 통신
- `@Shared(.appStorage("staffRole"))` - 사용자 역할
- `@Shared(.inMemory("UserSession"))` - 세션 정보

### Repository 레이어
**파일**: `Projects/Data/Repository/Sources/Profile/ProfileRepositoryImpl.swift`

**API 엔드포인트**:
- `GET /user/profile` - 프로필 조회
- `PUT /user/profile` - 프로필 편집

---

## 🧪 테스트 자동 생성 계획

### 1. ProfileUseCaseTest (12개 TC)

| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-044 | 프로필 조회 성공 | getProfile, staffRole 동기화 |
| TC-045 | UserSession 동기화 검증 | userID, name, generation 등 업데이트 |
| TC-046 | 매니저 프로필 조회 | Manager 권한 정보 포함 |
| TC-047 | 멤버 프로필 조회 | Member 기본 정보만 |
| TC-048 | 프로필 편집 성공 | editProfile 기본 정보 수정 |
| TC-049 | 매니저 권한 편집 | managerRoles 포함 편집 |
| TC-050 | 멤버 권한 편집 제한 | managerRoles 제외 편집 |
| TC-051 | 팀/직무 변경 검증 | selectTeam, selectPart 업데이트 |
| TC-052 | 기수 정보 검증 | generation 형식 및 유효성 |
| TC-053 | 초대 코드 검증 | Manager/Member 초대 코드 차이 |
| TC-054 | 프로필 권한 승급 시나리오 | Member → Manager 승급 |
| TC-055 | 프로필 데이터 일관성 | 권한-팀-직무 매칭 검증 |

### 2. ProfileRepositoryTest (4개 TC)

| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-056 | 프로필 조회 API | GET /user/profile |
| TC-057 | 프로필 편집 API | PUT /user/profile |
| TC-058 | API 요청 바디 검증 | EditProfileRequest 직렬화 |
| TC-059 | DTO 매핑 검증 | ProfileResponse → ProfileEntity |

---

## 👥 조직 구조 관리

### 팀 분류
- **iOS 팀**: iOS1, iOS2
- **Android 팀**: Android1, Android2
- **Web 팀**: Web1, Web2

### 직무 분류
- **개발**: iOS, Android, Frontend, Backend
- **기획**: PM, Designer

### 기수 시스템
- **1기**: 주로 Manager 권한
- **2기**: Manager/Member 혼재
- **3기**: 주로 Member 권한

### 권한 시스템
```swift
enum Staff {
    case manager
    case member
}

enum ManagerRole {
    case attendanceCheck  // 출석 체크 권한
    case photo           // 사진 권한
    case snsManagement   // SNS 관리 권한
}
```

---

## 🔧 자동화 도구 설정

### 클로드코드 서브에이전트 프롬프트
```
클로드코드 서브에이전트야, Profile 도메인을 상세 분석해줘:

1. ProfileUseCaseImpl.swift 프로필 관리 로직 분석
2. 권한 시스템 (Manager vs Member) 분석
3. 팀/직무/기수 매칭 규칙 분석
4. UserSession 상태 동기화 패턴 분석
5. EditProfileInput 유효성 검사 로직 분석

참고 PR 스타일 테스트 생성:
- 권한별 프로필 조회 테스트
- 팀/직무 매칭 검증 테스트
- 권한 승급 시나리오 테스트
```

---

## ✅ 검증 기준

### 권한 관리
- Manager/Member 권한 정확한 구분
- managerRoles 설정/해제 정확성
- 권한 승급 프로세스 검증

### 데이터 일관성
- 팀-직무-권한 매칭 검증
- 기수별 권한 패턴 확인
- UserSession 동기화 정확성

### 초대 시스템
- Manager/Member 초대 코드 차이
- 초대 코드 유효성 검증
- 신규 사용자 권한 설정

---

🎯 **목표**: 사용자 권한 시스템과 조직 구조 관리의 정확성을 보장하는 완전한 테스트 커버리지 달성