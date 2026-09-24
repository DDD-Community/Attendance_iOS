//
//  AppStateTests.swift
//  DDDAttendanceTests
//
//  Created by DDD on 2026-09-02.
//

import Testing
import SwiftUI
import UIKit

@testable import DDDAttendance

import ComposableArchitecture
import TCAFlow

@Suite("App State")
struct AppStateTests {
  @MainActor
  @Test("중첩 가입 라우터는 이름 다음 직무 화면까지 표시한다")
  func nestedOnboardingDisplaysSecondPush() async throws {
    func makeRoutes() -> Store<[Route<Int>], IndexedRouterAction<Int, Int>> {
      Store(initialState: [Route<Int>.root(0)]) {
        Reduce { state, action in
          if case let .updateRoutes(routes) = action { state = routes }
          return .none
        }
      }
    }
    let parent = makeRoutes()
    let child = makeRoutes()
    var appeared: Set<Int> = []
    let host = UIHostingController(rootView:
      TCAFlowRouter(parent) { screen in
        if screen.store.withState({ $0 }) == 0 {
          Text("Login")
        } else {
          TCAFlowRouter(child) { nested in
            let index = nested.store.withState { $0 }
            Text("Onboarding \(index)")
              .onAppear { appeared.insert(index) }
          }
        }
      }
    )
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    window.rootViewController = host
    window.makeKeyAndVisible()
    defer {
      window.isHidden = true
      window.rootViewController = nil
    }
    parent.send(.updateRoutes([.root(0), .push(1)]))
    for _ in 0..<100 where !appeared.contains(0) {
      try await Task.sleep(for: .milliseconds(20))
    }
    try #require(appeared.contains(0))
    child.send(.updateRoutes([.root(0), .push(1)]))
    for _ in 0..<100 where !appeared.contains(1) {
      try await Task.sleep(for: .milliseconds(20))
    }
    try #require(appeared.contains(1))
    child.send(.updateRoutes([.root(0), .push(1), .push(2)]))
    for _ in 0..<100 where !appeared.contains(2) {
      try await Task.sleep(for: .milliseconds(20))
    }
    #expect(appeared.contains(2), "이름 뒤 직무 화면이 실제 표시되어야 한다")
  }

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
