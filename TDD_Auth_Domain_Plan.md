# 🔐 Auth 도메인 TDD 자동화 계획서

## 📋 도메인 개요
**Auth 도메인**은 사용자 인증, 권한 관리, 토큰 관리를 담당하는 핵심 보안 도메인입니다.

---

## 🏗️ 아키텍처 구조

### UseCase 레이어
**파일**: `Projects/Domain/UseCase/Sources/Auth/AuthUseCaseImpl.swift`

**주요 메서드**:
- `login(provider: SocialType, token: String)` → 소셜 로그인
- `refresh()` → 토큰 갱신
- `logout()` → 로그아웃 + 상태 초기화
- `withDraw(token: String)` → 회원탈퇴 + 데이터 삭제
- `updateSessionCredential(with: AuthTokens)` → 세션 자격증명 업데이트

**의존성**:
- `@Dependency(\.authRepository)` - API 통신
- `@Dependency(\.keychainManager)` - 토큰 저장
- `@Shared(.appStorage("staffRole"))` - 사용자 역할 (Manager/Member)
- `@Shared(.inMemory("UserSession"))` - 세션 정보

### Repository 레이어
**파일**: `Projects/Data/Repository/Sources/Auth/AuthRepositoryImpl.swift`

**API 엔드포인트**:
- `POST /auth/login` - 소셜 로그인
- `POST /auth/refresh` - 토큰 갱신
- `DELETE /auth/logout` - 로그아웃
- `DELETE /user` - 회원탈퇴

---

## 🧪 테스트 자동 생성 계획

### 1. AuthUseCaseTest (15개 TC)

| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-001 | Google 로그인 성공 | provider=.google, 토큰 저장, UserSession 업데이트 |
| TC-002 | Apple 로그인 성공 | provider=.apple, oauthRefreshToken=nil |
| TC-003 | 신규 사용자 로그인 | isNewUser=true, role=nil |
| TC-004 | 로그인 실패 (잘못된 토큰) | InvalidToken Error 처리 |
| TC-005 | 로그인 실패 (네트워크 오류) | Network Error 처리 |
| TC-006 | 토큰 갱신 성공 | 새로운 Access/Refresh Token |
| TC-007 | 토큰 갱신 실패 (만료) | TokenExpired Error |
| TC-008 | 로그아웃 성공 + 상태 초기화 | staffRole=nil, Keychain.clear() |
| TC-009 | 로그아웃 실패 | Server Error 처리 |
| TC-010 | 회원탈퇴 성공 + 데이터 삭제 | isSuccess=true, Keychain.clear() |
| TC-011 | 회원탈퇴 실패 (권한 없음) | Unauthorized Error |
| TC-012 | 세션 자격증명 업데이트 | updateSessionCredential 호출 |
| TC-013 | 로그인→로그아웃 전체 플로우 | End-to-End 시나리오 |
| TC-014 | 토큰 길이 경계값 검증 | 짧은/긴 토큰 처리 |
| TC-015 | 동시 로그인 요청 처리 | Concurrency 검증 |

**Mock 의존성**:
```swift
struct MockAuthRepository: AuthRepositoryInterface
struct MockKeychainManager: KeychainManaging
enum AuthError: Error
```

### 2. AuthRepositoryTest (8개 TC)

| TC 번호 | 테스트 케이스 | 검증 항목 |
|---------|-------------|-----------|
| TC-016 | 로그인 API 호출 성공 | POST /auth/login 응답 검증 |
| TC-017 | 로그인 API 실패 (401) | 인증 실패 에러 처리 |
| TC-018 | 토큰 갱신 API 호출 | POST /auth/refresh 헤더/바디 검증 |
| TC-019 | 로그아웃 API 호출 | DELETE /auth/logout Bearer 토큰 |
| TC-020 | 회원탈퇴 API 호출 | DELETE /user 토큰 검증 |
| TC-021 | API 응답 DTO 매핑 | LoginResponse → LoginEntity |
| TC-022 | 네트워크 에러 처리 | Timeout, No Connection |
| TC-023 | API 인증 헤더 검증 | Authorization Bearer 형식 |

---

## 🔧 자동화 도구 설정

### 클로드코드 서브에이전트 프롬프트
```
클로드코드 서브에이전트야, Auth 도메인을 상세 분석해줘:

1. AuthUseCaseImpl.swift 메서드별 비즈니스 로직 분석
2. OAuth 플랫폼별 차이점 (Google vs Apple)
3. Keychain 보안 저장 패턴 분석
4. staffRole/UserSession 상태 관리 분석
5. 에러 처리 및 예외 상황 분석

참고 PR 스타일로 테스트 생성:
- @Suite("Auth UseCase Tests", .tags(.unit, .auth))
- Given-When-Then 구조
- withDependencies 사용
- #expect 상세 검증
```

### 예상 산출물
```
Projects/Domain/UseCase/UseCaseTests/Sources/Auth/AuthUseCaseTest.swift
Projects/Data/Repository/RepositoryTests/Sources/Auth/AuthRepositoryTest.swift
```

---

## ✅ 검증 기준

### 보안 검증
- 토큰 저장/삭제 완전성
- OAuth 플랫폼별 정책 준수
- 인증 실패 시 적절한 에러 처리
- 세션 상태 동기화 정확성

### 비즈니스 로직 검증
- 신규 vs 기존 사용자 구분
- Manager vs Member 권한 차이
- 로그인/로그아웃 플로우 완전성

---

🎯 **목표**: Auth 도메인의 보안성과 안정성을 보장하는 완전한 테스트 커버리지 달성