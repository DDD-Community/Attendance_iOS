클로드코드 서브에이전트야, 모든 도메인을 상세 분석해줘:

## 🎯 전체 도메인 분석 요청

### 1. **Attendance 도메인** 분석:
   - 파일 위치: Projects/Domain/UseCase/Sources/Attendance/
   - 출석 체크, 통계, 팀별 관리 로직
   - @Dependency(attendanceRepository) 의존성
   - @Shared(staffRole) 권한 관리
   - 출석 상태 변경 규칙

### 2. **Auth 도메인** 분석:
   - 파일 위치: Projects/Domain/UseCase/Sources/Auth/
   - Google/Apple 로그인, 토큰 관리
   - OAuth 플로우, 세션 관리
   - Keychain 보안 처리
   - 로그아웃/회원탈퇴 플로우

### 3. **Profile 도메인** 분석:
   - 파일 위치: Projects/Domain/UseCase/Sources/Profile/
   - 사용자 정보 수정, 이미지 업로드
   - 개인정보 검증 로직
   - 설정 관리, 알림 설정

### 4. **Schedule 도메인** 분석:
   - 파일 위치: Projects/Domain/UseCase/Sources/Schedule/
   - 일정 생성/수정/삭제
   - 시간 충돌 검증, 권한 제어
   - 일정 상태 관리 (예정/진행/완료)

### 5. **MyPage 도메인** 분석:
   - 파일 위치: Projects/Domain/UseCase/Sources/MyPage/
   - 개인 출석 기록, 통계
   - 개인별 일정 조회
   - 알림 설정 관리

### 6. **QRCode 도메인** 분석:
   - 파일 위치: Projects/Domain/UseCase/Sources/QRCode/
   - QR 스캔 로직, 검증
   - 출석 체크 연동
   - 중복 처리 방지

### 7. **OnBoarding 도메인** 분석:
   - 파일 위치: Projects/Domain/UseCase/Sources/OnBoarding/
   - 온보딩 단계 관리
   - 권한 요청 처리
   - 팀 선택/등록

### 8. **Manager 도메인** 분석:
   - 파일 위치: Projects/Domain/UseCase/Sources/Manager/
   - 관리자 대시보드
   - 팀원 관리, 권한 설정
   - 시스템 전역 설정

## 📊 공통 분석 항목

각 도메인별로 다음 항목들을 분석해줘:

1. **UseCase 구조**:
   - public 메서드들과 시그니처
   - @Dependency 의존성들  
   - @Shared 상태 관리
   - async/await 패턴
   - 에러 처리 방식

2. **Repository 구조**:
   - 파일 위치: Projects/Data/Repository/Sources/{Domain}/
   - API 호출 메서드들
   - DTO → Entity 매핑
   - 네트워크 에러 처리

3. **Entity 구조**:
   - Mock 데이터 확장 메서드들
   - 비즈니스 로직 검증 포인트
   - 도메인별 특화 규칙

4. **TCA Integration**:
   - Feature State 구조
   - Action 처리 방식
   - Effect 비동기 처리
   - Navigation 패턴

## 🎯 테스트 중점 영역

### 보안 중요 도메인:
- **Auth**: 토큰 관리, OAuth 보안
- **Profile**: 개인정보 보호

### 비즈니스 로직 핵심:
- **Attendance**: 출석 규칙, 권한 제어
- **Schedule**: 일정 관리, 시간 검증

### 사용자 경험:
- **MyPage**: 개인화 기능
- **QRCode**: 스캔 정확성
- **OnBoarding**: 사용자 가이드

### 관리 기능:
- **Manager**: 시스템 관리, 권한 설정

분석 결과를 **TDD_UseCase_Repository_TestPlan.md의 106개 테스트 케이스** 생성에 활용할 수 있도록 구조화해줘!