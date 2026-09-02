//
//  DDDDataRequestTests.swift
//  DDDNetwork
//
//  엔드포인트 선언이 URLRequest 로 옮겨지는 규칙을 검증한다.
//  Copyright © 2026 DDD. All rights reserved.
//

import Alamofire
import Foundation
import Testing

@testable import DDDNetwork
import DDDNetworkInterface

/// Moya 처럼 한 enum 에 여러 케이스를 두는 선언 방식. A 방식이 성립하는지 확인하는 대상이기도 하다.
private enum SampleService: DDDDataRequest {
  case list(page: Int)
  case create(name: String)
  case remove(id: Int)

  var path: String {
    switch self {
    case .list: "api/items"
    case .create: "api/items"
    case let .remove(id): "api/items/\(id)"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .list: .get
    case .create: .post
    case .remove: .delete
    }
  }

  var parameters: (any Encodable & Sendable)? {
    switch self {
    case let .list(page): ["page": page]
    case let .create(name): ["name": name]
    case .remove: nil
    }
  }
}

@Suite("DDDDataRequest — URLRequest 변환")
struct DDDDataRequestTests {
  private let baseURL = URL(string: "https://example.com")!

  @Test("path 가 baseURL 뒤에 붙는다")
  func buildsURL() throws {
    let request = try SampleService.remove(id: 7).asURLRequest(baseURL: baseURL)
    #expect(request.url?.absoluteString == "https://example.com/api/items/7")
  }

  @Test("method 가 그대로 실린다")
  func carriesMethod() throws {
    let request = try SampleService.create(name: "a").asURLRequest(baseURL: baseURL)
    #expect(request.httpMethod == "POST")
  }

  @Test("GET 은 파라미터를 쿼리스트링으로 보낸다")
  func encodesGetAsQuery() throws {
    let request = try SampleService.list(page: 3).asURLRequest(baseURL: baseURL)
    #expect(request.url?.query?.contains("page=3") == true)
    #expect(request.httpBody == nil)
  }

  @Test("POST 는 파라미터를 JSON 바디로 보낸다")
  func encodesPostAsJSONBody() throws {
    let request = try SampleService.create(name: "hello").asURLRequest(baseURL: baseURL)
    let body = try #require(request.httpBody)
    #expect(String(decoding: body, as: UTF8.self).contains("\"name\":\"hello\""))
    #expect(request.url?.query == nil)
  }

  @Test("파라미터가 없으면 바디도 쿼리도 만들지 않는다")
  func omitsEmptyParameters() throws {
    let request = try SampleService.remove(id: 1).asURLRequest(baseURL: baseURL)
    #expect(request.httpBody == nil)
    #expect(request.url?.query == nil)
  }

  @Test("타임아웃을 선언하지 않으면 세션 기본값을 쓴다")
  func keepsDefaultTimeout() throws {
    #expect(SampleService.list(page: 1).timeoutInterval == nil)
  }

  @Test("인증 정책 기본값은 automatic 이다")
  func defaultsToAutomaticAuthorization() {
    #expect(SampleService.list(page: 1).authorization == .automatic)
  }
}
