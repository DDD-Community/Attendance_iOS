//
//  AppStateTests.swift
//  DDDAttendanceTests
//
//  Created by DDD on 2026-09-02.
//

import Testing

@testable import DDDAttendance

@Suite("App State")
struct AppStateTests {
  @Test("앱 초기 상태는 Splash 화면이다")
  func initialStateStartsFromSplash() {
    let state = AppReducer.State()

    guard case .splash = state else {
      Issue.record("AppReducer.State 기본값은 splash여야 한다")
      return
    }
  }
}
