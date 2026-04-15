# 개발 환경 설정 가이드

## 🔧 개발 환경 Commands

### Make 명령어

| 명령어 | 설명 |
|--------|------|
| `./make generate` | Xcode 프로젝트 생성 |
| `./make build` | clean → install → generate 순차 실행 |
| `./make install` | 의존성 설치 |
| `./make clean` | 프로젝트 정리 |

### Xcode 빌드

```bash
# 빌드
xcodebuild -workspace DDDAttendance.xcworkspace -scheme DDDAttendance build

# 테스트 실행  
xcodebuild -workspace DDDAttendance.xcworkspace -scheme DDDAttendance test
```

### ⚠️ 중요 규칙

1. **파일 생성/삭제 시**: 반드시 `./make generate` 실행
2. **`Project.swift` 수정 시**: 반드시 `./make generate` 실행  
3. **의존성 추가/제거 시**: `./make install` → `./make generate` 순서로 실행
4. **Tuist glob 특성**: generate 없이는 Xcode에 새 파일이 반영되지 않음

## 📚 참고사항

### 테스트 패턴

```swift
// TCA TestStore 패턴
func testLogin() async {
    let store = TestStore(initialState: LoginFeature.State()) {
        LoginFeature()
    }
    
    await store.send(.loginButtonTapped) {
        $0.isLoading = true
    }
    
    await store.receive(.loginResponse(.success(mockUser))) {
        $0.isLoading = false
        $0.user = mockUser
    }
}
```

### 성능 고려사항

- **TCA State**: `@ObservableState` + `Equatable` 구현으로 불필요한 렌더링 방지
- **Effect 최적화**: `.run` 내에서 Heavy 작업 처리, UI 업데이트는 MainActor
- **의존성 주입**: 싱글톤 패턴 최소화, Interface 기반 테스트 용이성 확보

**이 가이드는 에이전트들이 개발 환경 설정을 분석하고 최적화할 때 참고하는 기준입니다.**