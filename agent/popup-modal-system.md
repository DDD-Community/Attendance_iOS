# 팝업 & 모달 시스템 가이드

프로젝트에서는 **3가지 방식**의 팝업/모달 시스템을 제공합니다.

## 1. CustomAlert (TCA 기반 커스텀 알림)

### State 정의

```swift
@Reducer
public struct FeatureName {
  @ObservableState
  public struct State: Equatable {
    // CustomAlert 상태
    @Presents public var customAlert: CustomAlertState<CustomAlertAction>?
    var customAlertMode: CustomAlertMode? = nil
  }
  
  public enum Action {
    case view(View)
    case inner(InnerAction)
    case customAlert(PresentationAction<CustomAlertAction>)
  }
  
  // CustomAlert 모드 정의
  public enum CustomAlertMode: Equatable {
    case loginRequired
    case locationPermissionRequired
    case withdrawAccount
  }
}
```

### Reducer 구성

```swift
public var body: some ReducerOf<Self> {
  Reduce { state, action in
    // 액션 처리
  }
  .ifLet(\.$customAlert, action: \.customAlert) {
    CustomConfirmAlert()
  }
}

// CustomAlert 핸들러 (Extension)
extension FeatureName {
  private func handleCustomAlertAction(
    state: inout State,
    action: PresentationAction<CustomAlertAction>
  ) -> Effect<Action> {
    switch action {
    case .presented(.confirmTapped):
      switch state.customAlertMode {
      case .loginRequired:
        state.customAlert = nil
        state.customAlertMode = nil
        return .send(.delegate(.presentAuth))
        
      case .withdrawAccount:
        state.customAlert = nil
        return .send(.inner(.performWithdraw))
        
      case .none:
        state.customAlert = nil
        return .none
      }
      
    case .presented(.cancelTapped), .dismiss:
      state.customAlert = nil
      state.customAlertMode = nil
      return .none
      
    case .presented(.policyTapped):
      return .send(.inner(.presentPrivacyPolicy))
    }
  }
}
```

### View에서 사용

```swift
struct FeatureView: View {
  @Bindable var store: StoreOf<FeatureName>
  
  var body: some View {
    VStack {
      // 메인 콘텐츠
      Button("로그인 필요 액션") {
        store.send(.view(.loginRequiredAction))
      }
    }
    .customAlert($store.scope(state: \.customAlert, action: \.customAlert))
  }
}
```

### 미리 정의된 Alert 사용

```swift
// Action 처리에서 Alert 표시
case .loginRequiredAction:
  state.customAlert = .alert(
    title: "로그인이 필요합니다",
    message: "이 기능을 사용하려면 로그인해 주세요.",
    confirmTitle: "로그인",
    cancelTitle: "취소"
  )
  state.customAlertMode = .loginRequired
  return .none

// 미리 정의된 Alert들
state.customAlert = .withdrawAccount()  // 회원탈퇴 확인
state.customAlert = .logout()           // 로그아웃 확인
state.customAlert = .privacyPolicyConsent()  // 개인정보 동의
```

## 2. Toast 시스템 (전역 메시지)

### 기본 사용법

```swift
// TCA Reducer에서 Toast 표시
case .loginSuccess:
  ToastManager.shared.showSuccess("로그인에 성공했습니다!")
  return .none
  
case .loginFailure(let error):
  ToastManager.shared.showError("인증에 실패했어요. 다시 시도해주세요.")
  return .none
  
case .networkError:
  ToastManager.shared.showWarning("네트워크 연결을 확인해주세요.")
  return .none

case .insufficientWaitTime:
  ToastManager.shared.showWarning("대기 시간이 부족합니다 (최소 20분 필요)")
  return .none
```

### Toast 타입들

```swift
// 성공 메시지 (녹색)
ToastManager.shared.showSuccess("작업이 완료되었습니다!")

// 에러 메시지 (빨간색)  
ToastManager.shared.showError("오류가 발생했습니다.")

// 경고 메시지 (주황색)
ToastManager.shared.showWarning("주의가 필요합니다.")

// 정보 메시지 (파란색)
ToastManager.shared.showInfo("새로운 업데이트가 있습니다.")

// 로딩 메시지 (자동으로 사라지지 않음)
ToastManager.shared.showLoading("데이터를 불러오는 중...")

// 수동으로 숨기기
ToastManager.shared.hideToast()
```

### App에서 Toast 설정

```swift
struct App: View {
  var body: some View {
    ContentView()
      .overlay(
        ToastView()  // 앱 최상단에 Toast 오버레이
          .zIndex(999)
      )
  }
}
```

## 3. CustomModal (드래그 지원 모달)

### State 정의

```swift
@Reducer
public struct FeatureName {
  @ObservableState
  public struct State: Equatable {
    @Presents public var trainStationSheet: TrainStationFeature.State?
    @Presents public var profileEditSheet: ProfileEditFeature.State?
  }
  
  public enum Action {
    case trainStationSheet(PresentationAction<TrainStationFeature.Action>)
    case profileEditSheet(PresentationAction<ProfileEditFeature.Action>)
  }
}
```

### View에서 Modal 사용

```swift
struct FeatureView: View {
  @Bindable var store: StoreOf<FeatureName>
  
  var body: some View {
    VStack {
      Button("역 선택") {
        store.send(.view(.presentTrainStationSheet))
      }
    }
    .presentDSModal(
      item: $store.scope(state: \.trainStationSheet, action: \.trainStationSheet),
      height: .fraction(0.8),  // 화면의 80% 높이
      showDragIndicator: true
    ) { store in
      TrainStationView(store: store)
    }
    .presentDSModal(
      item: $store.scope(state: \.profileEditSheet, action: \.profileEditSheet),
      height: .fixed(600),  // 고정 높이
      showDragIndicator: false
    ) { store in
      ProfileEditView(store: store)
    }
  }
}
```

### Modal 높이 옵션

```swift
// 화면 비율 기준
.presentDSModal(height: .fraction(0.7))  // 70%

// 고정 높이
.presentDSModal(height: .fixed(500))     // 500pt

// 내용에 맞춤
.presentDSModal(height: .auto)           // 자동 조정
```

### Modal 내에서 닫기

```swift
struct ModalContentView: View {
  @Environment(\.modalDismiss) var dismiss
  
  var body: some View {
    VStack {
      Button("닫기") {
        dismiss()  // Environment를 통한 모달 닫기
      }
    }
  }
}
```

## 📋 팝업/모달 사용 가이드라인

### 언제 어떤 것을 사용할까?

```swift
// ✅ CustomAlert - 사용자 확인이 필요한 중요한 액션
state.customAlert = .withdrawAccount()  // 회원탈퇴
state.customAlert = .logout()          // 로그아웃

// ✅ Toast - 간단한 피드백 메시지 (자동으로 사라짐)
ToastManager.shared.showSuccess("저장되었습니다")
ToastManager.shared.showError("네트워크 오류")

// ✅ CustomModal - 복잡한 UI가 필요한 경우
.presentDSModal(item: $store.trainStationSheet) { store in
  TrainStationView(store: store)  // 전체 화면이 필요한 기능
}
```

## 🏗️ TCA Presentation 패턴 규칙

1. **@Presents**: 모든 팝업/모달 상태는 `@Presents` 사용
2. **PresentationAction**: 액션에 `PresentationAction<ChildAction>` 포함
3. **ifLet**: Reducer에서 `.ifLet` 연산자로 자식 기능 연결
4. **State 초기화**: 팝업 표시 시 자식 State를 새로 생성
5. **nil 할당**: 팝업 닫기 시 상태를 `nil`로 설정

**이 가이드는 에이전트들이 팝업/모달 시스템을 분석하고 최적화할 때 참고하는 기준입니다.**