//
//  OnBoardingNameReducerTests.swift
//  OnBoardingTests
//
//  Created by DDD on 2026-09-02
//

import ComposableArchitecture
import Entity
import Testing

@testable import OnBoarding

@MainActor
@Suite("OnBoardingName")
struct OnBoardingNameReducerTests {
  @Test("5자 이하 이름은 사용 가능하고 다음 화면 이동을 요청한다")
  func availableNameNavigatesToPartSelection() async {
    var state = OnBoardingName.State()
    state.userSession.name = "철수"
    let store = TestStore(initialState: state) {
      OnBoardingName()
    }

    await store.send(.view(.checkIsAvailableName)) {
      $0.isNotAvailableName = false
    }
    await store.receive(.navigation(.presentSignUpPart))
  }

  @Test("6자 이상 이름은 사용 불가로 표시하고 이동하지 않는다")
  func tooLongNameMarksUnavailable() async {
    var state = OnBoardingName.State()
    state.userSession.name = "홍길동입니다"
    let store = TestStore(initialState: state) {
      OnBoardingName()
    }

    await store.send(.view(.checkIsAvailableName)) {
      $0.isNotAvailableName = true
    }
  }
}
