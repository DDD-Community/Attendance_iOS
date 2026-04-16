# 📋 Attendance 도메인 TDD 자동화 계획서

## 📋 도메인 개요
**Attendance 도메인**은 출석 관리, 통계, 팀별 출석 현황을 담당하는 핵심 업무 도메인입니다.

---

## 🏗️ 아키텍처 구조

### UseCase 레이어
**파일**: `Projects/Domain/UseCase/Sources/Attendance/AttendanceUseCaseImpl.swift`

**주요 메서드**:
- `adminAttendanceCount(scheduleId: Int)` → 관리자 출석 통계 조회
- `fetchAttendanceTeams()` → 출석 관리 가능한 팀 목록
- `sessionAttendance(scheduleId: Int, teamId: Int)` → 세션별 출석 현황
- `fetchStatus()` → 출석 상태 종류 (참석/지각/결석)
- `editAttendance(input: EditAttendanceInput)` → 출석 현황 수정

**의존성**:
- `@Dependency(\.attendanceRepository)` - API 통신
- `@Shared(.appStorage("staffRole"))` - Manager/Member 권한 검증

### Repository 레이어
**파일**: `Projects/Data/Repository/Sources/Attendance/AttendanceRepositoryImpl.swift`

**API 엔드포인트**:
- `GET /attendance/admin/count` - 출석 통계
- `GET /attendance/teams` - 팀 목록
- `GET /attendance/session` - 세션 출석 현황
- `PUT /attendance/edit` - 출석 수정

---

## 🧪 테스트 자동 생성 계획

### 1. AttendanceUseCaseTest (13개 TC)

| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-024 | 관리자 출석 통계 조회 성공 | adminAttendanceCount 응답 검증 |
| TC-025 | 출석 가능 팀 목록 조회 | fetchAttendanceTeams 권한별 필터링 |
| TC-026 | 특정 일정 출석 현황 조회 | sessionAttendance 팀별/일정별 데이터 |
| TC-027 | 출석 상태 종류 조회 | fetchStatus (참석/지각/결석) |
| TC-028 | 출석 현황 수정 성공 | editAttendance 성공 플로우 |
| TC-029 | 출석 수정 실패 (권한 없음) | Member의 타인 출석 수정 시도 |
| TC-030 | 출석 수정 실패 (잘못된 데이터) | 유효하지 않은 scheduleId, teamId |
| TC-031 | 출석 통계 계산 검증 | 참석/지각/결석 수 계산 로직 |
| TC-032 | 팀별 출석 데이터 필터링 | iOS/Android/Web 팀 분리 |
| TC-033 | 출석 상태 변경 플로우 | 참석→지각, 참석→결석 변경 |
| TC-034 | 출석 데이터 일관성 검증 | scheduleId, userId 매칭 |
| TC-035 | 출석 수정 권한 검증 | Manager vs Member 권한 차이 |
| TC-036 | 출석 기록 히스토리 검증 | 수정 전후 상태 비교 |

### 2. AttendanceRepositoryTest (7개 TC)

| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-037 | 출석 통계 조회 API | GET /attendance/admin/count |
| TC-038 | 팀 목록 조회 API | GET /attendance/teams |
| TC-039 | 출석 현황 조회 API | GET /attendance/session |
| TC-040 | 출석 수정 API | PUT /attendance/edit |
| TC-041 | API 쿼리 파라미터 검증 | scheduleId, teamId 전달 |
| TC-042 | API 응답 에러 처리 | 400, 403, 500 에러 |
| TC-043 | DTO 매핑 검증 | AttendanceResponse → Attendance |

---

## 📊 출석 비즈니스 로직

### 출석 상태 분류
- **참석 (attended)**: 정상 출석
- **지각 (late)**: 늦은 출석
- **결석 (absent)**: 미출석

### 팀별 권한 관리
- **Manager**: 모든 팀 출석 관리 가능
- **Member**: 자신의 출석만 확인 가능

### 통계 계산 규칙
```swift
totalCount = attendanceCount + lateCount + absentCount
attendanceRate = (attendanceCount / totalCount) * 100
```

---

## 🔧 자동화 도구 설정

### 클로드코드 서브에이전트 프롬프트
```
클로드코드 서브에이전트야, Attendance 도메인을 상세 분석해줘:

1. AttendanceUseCaseImpl.swift 비즈니스 로직 분석
2. 팀별/권한별 데이터 접근 제어 분석
3. 출석 상태 변경 규칙 분석
4. 통계 계산 로직 검증
5. EditAttendanceInput 유효성 검사 분석

참고 PR 스타일 테스트 생성:
- 팀별 필터링 테스트
- 권한별 접근 제어 테스트
- 출석 통계 계산 검증
```

---

## ✅ 검증 기준

### 데이터 무결성
- 출석 데이터 일관성
- 팀/사용자 매칭 정확성
- 통계 계산 정확성

### 권한 관리
- Manager/Member 접근 제어
- 타인 출석 수정 방지
- 팀별 데이터 격리

---

🎯 **목표**: 출석 관리 시스템의 정확성과 권한 보안을 보장하는 완전한 테스트 커버리지 달성