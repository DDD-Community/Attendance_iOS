//
//  WebTests.swift
//  WebTests
//
//  Created by DDD on 9/1/26.
//

import Testing

@testable import Web

@Suite("Web")
struct WebTests {
  @Test("State 는 주입한 url 을 그대로 보관한다")
  func stateKeepsInjectedURL() {
    let state = WebReducer.State(url: "https://example.com")
    #expect(state.url == "https://example.com")
  }
}
