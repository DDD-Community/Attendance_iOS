# Git 워크플로우 가이드

## 🎯 Git 규칙

### 브랜치 전략

- **`main`**: 배포용 브랜치
- **`develop`**: 통합 개발 브랜치  
- **`feature/#{issue-number}`**: 기능 개발 브랜치

### 커밋 메시지 컨벤션

```
[{Header}]: {Message}

Header 종류:
- FEAT: 새 기능 추가
- REFACTOR: 코드 리팩토링 (기능 변경 없음)
- ADD: 파일, 의존성 추가
- FIX: 버그 수정
- HOTFIX: 긴급 버그 수정
- DOCS: 문서 수정
- TEST: 테스트 코드 작성/수정
- CHORE: 기타 작업 (빌드, 설정 등)

예시:
[FEAT]: 로그인 화면 UI 구현
[REFACTOR]: AuthRepository DI 패턴 적용
[FIX]: 토큰 만료 시 자동 갱신 로직 수정
```

### Git 규칙

- **메시지**: 한국어 사용, 한 줄, 최대 50자
- **특수기호**: 마침표, 특수기호 사용 금지
- **PR**: `feature/#{issue}` → `develop` 머지
- **Body**: 필요시 작성, 무엇을 왜 변경했는지 기술

## 🔄 Git 작업 플로우

### 1. 커밋 후 푸시
```bash
# 변경사항 스테이징
git add .

# 커밋 (한국어 메시지)
git commit -m "[FEAT]: 기능 설명"

# 푸시
git push origin feature/브랜치명
```

### 2. 푸시 규칙
- **브랜치 푸시**: 작업 완료 후 즉시 원격 브랜치에 푸시
- **Force Push 금지**: `git push --force` 절대 사용 금지 (협업 시 충돌 방지)  
- **푸시 전 확인**: `git status`로 staged 파일 확인 후 푸시
- **브랜치명 확인**: `git branch`로 현재 브랜치 확인 후 푸시
- **메인 브랜치**: `develop` 브랜치에 직접 푸시 금지, PR 통해서만 머지

## 📋 Pull Request 규칙

### PR 크기 제한
- **파일 변경**: **30개 내외**로 제한 (최대 35개)
- **대형 PR 분할**: 기능별로 여러 PR로 나누어 리뷰 효율성 확보
- **단일 책임**: 하나의 PR은 하나의 기능/버그픽스에 집중

### PR 분할 전략

```bash
# ❌ 잘못된 예시 (너무 큰 PR)
feature/user-management
├── 회원가입 화면 (15개 파일)
├── 프로필 편집 (12개 파일)
├── 회원탈퇴 (8개 파일)
├── 설정 화면 (10개 파일)
└── 공통 컴포넌트 (8개 파일)
Total: 53개 파일 ❌

# ✅ 올바른 예시 (적절한 크기)
feature/user-signup        # 회원가입 (15개 파일)
feature/user-profile-edit  # 프로필 편집 (12개 파일) 
feature/user-withdrawal    # 회원탈퇴 (8개 파일)
feature/user-settings      # 설정 화면 (10개 파일)
feature/user-components    # 공통 컴포넌트 (8개 파일)
```

### 대형 작업 처리 방법

```bash
# 1단계: 기반 인프라 먼저
feature/auth-infrastructure
├── AuthError.swift
├── AuthInterface.swift  
├── AuthRepositoryImpl.swift
└── 기본 인증 구조 (20개 파일)

# 2단계: 개별 기능들
feature/auth-login         # 로그인 (25개 파일)
feature/auth-signup        # 회원가입 (30개 파일)
feature/auth-oauth         # 소셜 로그인 (28개 파일)
```

### PR 체크리스트

**작성 전 확인:**
- [ ] 파일 변경 개수가 30개 이내인가?
- [ ] 단일 기능/버그에 집중하고 있는가?
- [ ] 관련 없는 리팩토링이 포함되어 있지 않은가?

**PR 설명 필수 항목:**
- [ ] **What**: 무엇을 변경했는가
- [ ] **Why**: 왜 변경했는가  
- [ ] **How**: 어떻게 구현했는가
- [ ] **Test**: 어떻게 테스트했는가

### PR 템플릿

```markdown
## 📋 변경 내용
- [ ] 새 기능 추가
- [ ] 버그 수정
- [ ] 리팩토링
- [ ] 문서 업데이트
- [ ] 의존성 업데이트

## 🎯 작업 내용
<!-- 구체적인 변경 사항 나열 -->

## ✅ 테스트 완료 항목
- [ ] 로컬 빌드 성공
- [ ] 주요 기능 동작 확인
- [ ] UI 테스트 완료
- [ ] 기존 기능 영향도 확인

## 📸 스크린샷 (UI 변경 시)
<!-- Before/After 스크린샷 첨부 -->

## 📝 리뷰 포인트
<!-- 특별히 확인이 필요한 부분 -->

## 📚 참고 자료
<!-- 관련 이슈, 문서 링크 -->
```

### 리뷰어 가이드라인

**우선순위 체크:**
1. **아키텍처 준수**: TCA + Clean Architecture 패턴
2. **에러 처리**: Result 래퍼 + 적절한 에러 타입
3. **UI 일관성**: DesignSystem 컴포넌트 사용
4. **성능**: 불필요한 렌더링, 메모리 누수 확인
5. **보안**: API 키 노출, 민감 정보 처리

**리뷰 완료 조건:**
- [ ] 모든 CI 체크 통과
- [ ] 2명 이상의 Approve 
- [ ] 충돌(Conflict) 해결 완료
- [ ] 커밋 히스토리 정리 (squash 권장)

**이 가이드는 에이전트들이 Git 워크플로우를 분석하고 최적화할 때 참고하는 기준입니다.**