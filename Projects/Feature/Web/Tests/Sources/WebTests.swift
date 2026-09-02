//
//  WebTests.swift
//  WebTests
//
//  Created by DDD on 9/1/26.
//

import Testing
import ComposableArchitecture

@testable import Web

@MainActor
@Suite("Web")
struct WebTests {
  @Test("State 는 주입한 url 을 그대로 보관한다")
  func stateKeepsInjectedURL() {
    let state = WebReducer.State(url: "https://example.com")
    #expect(state.url == "https://example.com")
  }

  @Test("backToRoot 액션은 웹 URL 상태를 변경하지 않는다")
  func backToRootDoesNotMutateURL() async {
    let store = TestStore(initialState: WebReducer.State(url: "https://example.com/privacy")) {
      WebReducer()
    }

    await store.send(.backToRoot)
  }
}
