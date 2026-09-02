//
//  WebReducerTests.swift
//  WebTests
//
//  Created by DDD on 2026-09-02.
//

import ComposableArchitecture
import Testing

@testable import Web

@MainActor
@Suite("WebReducer")
struct WebReducerTests {
  @Test("초기화 때 전달한 URL을 State에 보관한다")
  func initStoresURL() {
    let state = WebReducer.State(url: "https://dddstudy.kr/privacy")

    #expect(state.url == "https://dddstudy.kr/privacy")
  }

  @Test("backToRoot 액션은 웹 상태를 변경하지 않는다")
  func backToRootDoesNotMutateState() async {
    let store = TestStore(initialState: WebReducer.State(url: "https://dddstudy.kr")) {
      WebReducer()
    }

    await store.send(.backToRoot)
  }
}
