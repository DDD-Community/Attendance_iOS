//
//  NetworkClientTests.swift
//  DDDNetworkTests
//
//  Created by DDD on 9/1/26.
//

import Alamofire
import Foundation
import Testing

@testable import DDDNetwork
import DDDNetworkInterface

@Suite("NetworkClient — 요청·응답 통합", .serialized)
struct NetworkClientTests {
  init() {
    URLProtocolStub.reset()
  }

  @Test("2xx 성공 응답을 모델로 디코딩한다")
  func success() async throws {
    URLProtocolStub.set(statusCode: 200, body: json(#"{"id":7,"name":"출석"}"#))

    let user = try await URLProtocolStub.makeClient().send(UserRequest())

    #expect(user == User(id: 7, name: "출석"))
    #expect(URLProtocolStub.recordedRequests.first?.url?.path == "/users/7")
  }

  @Test("4xx 응답의 code와 message를 ResponseError로 보존한다")
  func clientError() async {
    URLProtocolStub.set(
      statusCode: 400,
      body: json(#"{"code":"INVALID_REQUEST","message":"잘못된 요청"}"#)
    )

    await expectResponseError(UserRequest()) { error in
      #expect(error.httpStatus == 400)
      #expect(error.code == "INVALID_REQUEST")
      #expect(error.message == "잘못된 요청")
      #expect(error.isServerError == false)
    }
  }

  @Test("401 응답은 인증 실패로 분류한다")
  func unauthorized() async {
    URLProtocolStub.set(statusCode: 401, body: json(#"{"code":"TOKEN_EXPIRED"}"#))

    await expectResponseError(UserRequest()) { error in
      #expect(error.isUnauthorized)
      #expect(error.code == "TOKEN_EXPIRED")
    }
  }

  @Test("5xx 응답은 서버 오류로 분류한다")
  func serverError() async {
    URLProtocolStub.set(statusCode: 503, body: json("{}"))

    await expectResponseError(UserRequest()) { error in
      #expect(error.httpStatus == 503)
      #expect(error.isServerError)
      #expect(error.code == nil)
    }
  }

  @Test("인터넷 연결 실패는 transport.notConnected로 변환한다")
  func notConnected() async {
    URLProtocolStub.setError(URLError(.notConnectedToInternet))

    await expectTransportError(UserRequest()) { error in
      guard case .notConnected = error else {
        Issue.record("notConnected 기대, got \(error)")
        return
      }
    }
  }

  @Test("타임아웃은 transport.timedOut으로 변환한다")
  func timedOut() async {
    URLProtocolStub.setError(URLError(.timedOut))

    await expectTransportError(UserRequest()) { error in
      guard case .timedOut = error else {
        Issue.record("timedOut 기대, got \(error)")
        return
      }
    }
  }

  @Test("성공 응답의 JSON 형태가 다르면 decoding 에러로 변환한다")
  func decodingFailure() async {
    URLProtocolStub.set(statusCode: 200, body: json(#"{"id":"문자열"}"#))

    do {
      _ = try await URLProtocolStub.makeClient().send(UserRequest())
      Issue.record("decoding 에러가 발생해야 한다")
    } catch {
      guard case .decoding = error else {
        Issue.record("decoding 기대, got \(error)")
        return
      }
    }
  }

  @Test("204 빈 응답은 DDDEmptyResponse로 성공한다")
  func emptyResponse() async throws {
    URLProtocolStub.set(statusCode: 204)

    _ = try await URLProtocolStub.makeClient().send(PingRequest())
  }

  @Test("raw 응답은 실패 상태 코드와 바디를 그대로 보존한다")
  func rawResponse() async throws {
    let body = json(#"{"code":"WITHDRAW_FAILED","message":"탈퇴 실패"}"#)
    URLProtocolStub.set(statusCode: 400, body: body)

    let response = try await URLProtocolStub.makeClient().sendResponse(PingRequest())

    #expect(response.statusCode == 400)
    #expect(response.data == body)
  }

  @Test("raw 응답도 전송 실패는 DDDNetworkError로 변환한다")
  func rawResponseTransportFailure() async {
    URLProtocolStub.setError(URLError(.notConnectedToInternet))

    do {
      _ = try await URLProtocolStub.makeClient().sendResponse(PingRequest())
      Issue.record("transport 에러가 발생해야 한다")
    } catch {
      guard case .transport(.notConnected) = error else {
        Issue.record("transport.notConnected 기대, got \(error)")
        return
      }
    }
  }

  @Test("baseURL이 없으면 통신 전에 request.invalidURL로 실패한다")
  func missingBaseURL() async {
    do {
      _ = try await URLProtocolStub.makeClient(baseURL: nil).send(UserRequest())
      Issue.record("invalidURL 에러가 발생해야 한다")
    } catch {
      guard case .request(.invalidURL) = error else {
        Issue.record("request.invalidURL 기대, got \(error)")
        return
      }
    }
  }
}

private extension NetworkClientTests {
  func json(_ string: String) -> Data {
    Data(string.utf8)
  }

  func expectResponseError(
    _ request: some DDDDataRequest,
    assert: (ResponseError) -> Void
  ) async {
    do {
      _ = try await URLProtocolStub.makeClient().send(request)
      Issue.record("response 에러가 발생해야 한다")
    } catch {
      guard case let .response(responseError) = error else {
        Issue.record("response 기대, got \(error)")
        return
      }
      assert(responseError)
    }
  }

  func expectTransportError(
    _ request: some DDDDataRequest,
    assert: (TransportError) -> Void
  ) async {
    do {
      _ = try await URLProtocolStub.makeClient().send(request)
      Issue.record("transport 에러가 발생해야 한다")
    } catch {
      guard case let .transport(transportError) = error else {
        Issue.record("transport 기대, got \(error)")
        return
      }
      assert(transportError)
    }
  }
}

private struct UserRequest: DDDDataRequest {
  typealias Response = User

  let path = "users/7"
  let method: HTTPMethod = .get
  let maxRetryAttempts = 0
}

private struct PingRequest: DDDDataRequest {
  typealias Response = DDDEmptyResponse

  let path = "ping"
  let method: HTTPMethod = .get
  let maxRetryAttempts = 0
}

private struct User: Decodable, Equatable, Sendable {
  let id: Int
  let name: String
}
