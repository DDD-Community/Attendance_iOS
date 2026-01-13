//
//  AttendanceModalUsage.swift
//  Management
//
//  Created by Wonji Suh on 1/13/26.
//

import SwiftUI
// import ComposableArchitecture // TCA 사용 시 필요

// MARK: - Store Scope 패턴 사용 예제

/*
## ProfileReducer customAlert 패턴을 따른 AttendanceModal 사용법

### 1. Reducer에 상태 추가 (ProfileReducer와 동일한 패턴)

```swift
@Reducer
public struct YourFeature {
  @ObservableState
  public struct State: Equatable {
    // 다른 상태들...
    @Presents public var attendanceModal: AttendanceModalState<AttendanceModalAction>?
  }

  public enum Action: ViewAction, FeatureAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case scope(ScopeAction)
    case async(AsyncAction)
    case navigation(NavigationAction)
  }

  @CasePathable
  public enum View {
    case showAttendanceModal
    case showLateTimeModal
  }

  @CasePathable
  public enum ScopeAction {
    case attendanceModal(PresentationAction<AttendanceModalAction>)
  }

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
        case .view(let viewAction):
          return handleViewAction(state: &state, action: viewAction)

        case .scope(let scopeAction):
          switch scopeAction {
            case .attendanceModal(let action):
              return handleAttendanceModalAction(state: &state, action: action)
          }

        // 다른 액션들...
      }
    }
    .ifLet(\.$attendanceModal, action: \.scope.attendanceModal) {
      AttendanceModal()
    }
  }
}
```

### 2. ViewAction 처리 (ProfileReducer.showWithdrawAlert 패턴)

```swift
private func handleViewAction(
  state: inout State,
  action: View
) -> Effect<Action> {
  switch action {
    case .showAttendanceModal:
      state.attendanceModal = .changeAttendanceStatus(
        availableStatuses: [.attended, .late, .absent]
      )
      return .none

    case .showLateTimeModal:
      state.attendanceModal = .lateTimeStatusChange()
      return .none
  }
}
```

### 3. AttendanceModal 액션 처리 (ProfileReducer.handleCustomAlertAction 패턴)

```swift
private func handleAttendanceModalAction(
  state: inout State,
  action: PresentationAction<AttendanceModalAction>
) -> Effect<Action> {
  switch action {
    case .presented(let attendanceModalAction):
      switch attendanceModalAction {
        case .confirmTapped(let statusName):
          // ProfileReducer처럼 title 기반 구분도 가능하지만, statusName으로 직접 처리
          state.attendanceModal = nil

          // API 호출 예시
          return .run { send in
            // await updateAttendanceStatus(statusName)
            await send(.async(.updateAttendanceStatus(statusName)))
          }

        case .cancelTapped:
          state.attendanceModal = nil
          return .none
      }

    case .dismiss:
      return .none
  }
}
```

### 4. View에서 사용 (ProfileView 패턴)

```swift
public struct YourView: View {
  @Bindable private var store: StoreOf<YourFeature>

  public var body: some View {
    VStack {
      Button("출석 상태 변경") {
        store.send(.view(.showAttendanceModal))
      }

      Button("늦은 시간 모달") {
        store.send(.view(.showLateTimeModal))
      }
    }
    // ProfileView와 동일한 패턴
    .ㄷ
  }
}
```

### 5. 사전 정의된 팩토리 메서드들 (ProfileReducer.withdrawAccount() 패턴)

```swift
// 기본 출석 상태 변경
state.attendanceModal = .changeAttendanceStatus(
  availableStatuses: [.attended, .late, .absent],
  currentStatus: .attended
)

// 늦은 시간 제한된 옵션
state.attendanceModal = .lateTimeStatusChange(
  availableStatuses: [.late, .absent]
)

// 관리자용 전체 상태 변경
state.attendanceModal = .adminStatusChange(
  currentStatus: .attended
)
```

### 6. 핵심 차이점: ProfileReducer vs AttendanceModal

**ProfileReducer customAlert:**
- `.confirmTapped` → title 기반으로 액션 구분
- 단순 확인/취소 팝업

**AttendanceModal:**
- `.confirmTapped(String)` → statusName 파라미터로 직접 전달
- 드롭다운 선택 후 상태명 반환

### 7. 실제 사용 시나리오

```swift
// 출석 체크 화면에서
Button("출석 상태 수정") {
  store.send(.view(.showAttendanceModal))
}

// 관리자 화면에서
Button("상태 변경: \(attendance.status.desc)") {
  store.send(.view(.showAdminModal(currentStatus: attendance.status)))
}

// 늦은 시간 체크
if isLateTime {
  store.send(.view(.showLateTimeModal))
}
```
*/

// MARK: - 실제 예제 코드 (참고용)

/*
@Reducer
struct ExampleFeature {
  @ObservableState
  struct State: Equatable {
    @Presents var attendanceModal: AttendanceModalState<AttendanceModalAction>?
  }

  enum Action: ViewAction, FeatureAction, BindableAction {
    case view(View)
    case scope(ScopeAction)
    case binding(BindingAction<State>)
  }

  @CasePathable
  enum View {
    case showAttendanceModal
  }

  @CasePathable
  enum ScopeAction {
    case attendanceModal(PresentationAction<AttendanceModalAction>)
  }

  var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
        case .view(.showAttendanceModal):
          state.attendanceModal = .changeAttendanceStatus(
            availableStatuses: [.attended, .late, .absent]
          )
          return .none

        case .scope(.attendanceModal(let action)):
          return handleAttendanceModalAction(state: &state, action: action)

        case .binding:
          return .none
      }
    }
    .ifLet(\.$attendanceModal, action: \.scope.attendanceModal) {
      AttendanceModal()
    }
  }

  private func handleAttendanceModalAction(
    state: inout State,
    action: PresentationAction<AttendanceModalAction>
  ) -> Effect<Action> {
    switch action {
      case .presented(.confirmTapped(let statusName)):
        // 실제 API 호출이나 상태 업데이트
        print("선택된 상태: \(statusName)")
        state.attendanceModal = nil
        return .none

      case .presented(.cancelTapped):
        state.attendanceModal = nil
        return .none

      case .dismiss:
        return .none
    }
  }
}

struct ExampleView: View {
  @Bindable var store: StoreOf<ExampleFeature>

  var body: some View {
    VStack {
      Button("출석 상태 변경") {
        store.send(.view(.showAttendanceModal))
      }
      .padding()
    }
    .attendanceModal($store.scope(state: \.attendanceModal, action: \.scope.attendanceModal))
  }
}
*/
