//
//  OnBoardingNameReducerTests.swift
//  OnBoardingTests
//
//  Created by DDD on 2026-09-02
//

import Testing

@testable import OnBoarding

import ComposableArchitecture

@MainActor
@Suite("OnBoardingNameFeature")
struct OnBoardingNameReducerTests {
  @Test("입력한 이름으로 다음 이동을 요청한다", arguments: ["서원지", "가나다라마"])
  func enteredNameNavigates(name: String) async {
    var state = OnBoardingNameFeature.State()
    // 매개변수 케이스끼리 같은 영속 키의 세션을 공유하지 않도록 분리한다.
    state.$userSession = Shared(value: .empty)
    let store = TestStore(initialState: state) {
      OnBoardingNameFeature()
    }
    await store.send(.view(.nameChanged(name))) {
      $0.$userSession.withLock { $0.name = name }
    }
    #expect(store.state.userSession.name == name)
    #expect(store.state.enableButton)
    await store.send(.view(.checkIsAvailableName))
    await store.receive(\.delegate.presentSignUpPart)
  }

  @Test("입력 수정은 이전 오류를 해제하고 현재 입력을 5자로 제한한다")
  func editingNameClearsErrorAndLimitsCurrentValue() async {
    var state = OnBoardingNameFeature.State()
    state.isNotAvailableName = true
    let store = TestStore(initialState: state) { OnBoardingNameFeature() }
    await store.send(.view(.nameChanged("가나다라마바"))) {
      $0.$userSession.withLock { $0.name = "가나다라마" }
      $0.isNotAvailableName = false
    }
    #expect(store.state.enableButton)
    await store.send(.view(.nameChanged(""))) {
      $0.$userSession.withLock { $0.name = "" }
    }
    #expect(store.state.enableButton == false)
    await store.send(.view(.checkIsAvailableName))
  }

  @Test("5자 이하 이름은 사용 가능하고 다음 화면 이동을 요청한다")
  func availableNameNavigatesToPartSelection() async {
    var state = OnBoardingNameFeature.State()
    state.userSession.name = "철수"
    // 이전 검증에서 남은 사용 불가 표시가 해제되는지 확인한다
    state.isNotAvailableName = true
    let store = TestStore(initialState: state) {
      OnBoardingNameFeature()
    }

    await store.send(.view(.checkIsAvailableName)) {
      $0.isNotAvailableName = false
    }
    await store.receive(\.delegate.presentSignUpPart)
  }

  @Test("6자 이상 이름은 사용 불가로 표시하고 이동하지 않는다")
  func tooLongNameMarksUnavailable() async {
    var state = OnBoardingNameFeature.State()
    state.userSession.name = "홍길동입니다"
    let store = TestStore(initialState: state) {
      OnBoardingNameFeature()
    }

    await store.send(.view(.checkIsAvailableName)) {
      $0.isNotAvailableName = true
    }
  }
}
