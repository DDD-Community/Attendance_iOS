//
//  AppStateTests.swift
//  DDDAttendanceTests
//
//  Created by DDD on 2026-09-02.
//

import Testing

@testable import DDDAttendance

import ComposableArchitecture
import TCAFlow

@Suite("App State")
struct AppStateTests {
  @MainActor
  @Test("이름 입력 후 다음 액션은 실제 온보딩 직무 화면을 추가한다")
  func enteredNamePushesPartSelection() async {
    var state = OnBoardingCoordinator.State()
    state.routes.append(.push(.onBoardingName(.init())))
    let store = Store(initialState: state) { OnBoardingCoordinator() }

    await store.send(.router(.routeAction(
      id: 1, action: .onBoardingName(.view(.nameChanged("서원지")))
    ))).finish()
    await store.send(.router(.routeAction(
      id: 1, action: .onBoardingName(.view(.checkIsAvailableName))
    ))).finish()

    #expect(store.routes.count == 3)
    guard case .selectPart = store.routes.last?.screen else {
      Issue.record("이름 확인 후 직무 선택 화면으로 이동해야 한다")
      return
    }
  }

  @Test("앱 초기 상태는 Splash 화면이다")
  func initialStateStartsFromSplash() {
    let state = AppReducer.State()

    guard case .splash = state else {
      Issue.record("AppReducer.State 기본값은 splash여야 한다")
      return
    }
  }
}
