# TDD 자동화 스킬

이 스킬은 iOS 프로젝트에서 자동화된 TDD(Test-Driven Development) 워크플로우를 실행합니다.

## 기능

1. **도메인 분석**: Explore 에이전트로 도메인 구조 파악
2. **테스트 계획**: Plan 에이전트로 테스트 전략 수립
3. **테스트 작성**: 도메인별 단위 테스트 생성
4. **테스트 실행**: xcodebuild test로 실행
5. **실패 수정**: 테스트 실패 시 자동 수정
6. **PR 생성**: 모든 테스트 통과 시 자동 PR

## 지원 도메인

- Attendance (출석 관리)
- Auth (인증)
- Profile (프로필)
- Schedule (스케줄)
- OnBoarding (온보딩)
- QRCode (QR코드)
- MyPage (마이페이지)
- SignUp (회원가입)
- OAuth (Apple/Google)

## 사용법

```bash
/tdd-automation [domain] [options]
```

### 옵션

- `domain`: 특정 도메인만 테스트 (옵션, 없으면 전체)
- `--pr-title`: PR 제목 커스텀
- `--skip-existing`: 기존 테스트 파일 건너뛰기

### 예시

```bash
/tdd-automation attendance
/tdd-automation --pr-title "Add comprehensive test coverage"
/tdd-automation auth profile
```

## 아키텍처

- **TCA (The Composable Architecture)**: 상태 관리
- **WeaveDI**: 의존성 주입
- **XCTest + Swift Testing**: 테스트 프레임워크
- **Mock 데이터**: DTO.mockData() 활용