//
//  URLProtocolStub.swift
//  DDDNetworkTests
//
//  Created by DDD on 9/1/26.
//

import Alamofire
import Foundation

@testable import DDDNetwork

/// 실제 통신 없이 `NetworkClient`의 요청과 응답을 검증하는 URLProtocol 스텁.
/// 정적 상태를 사용하므로 이 스텁을 사용하는 테스트 스위트는 직렬로 실행해야 한다.
final class URLProtocolStub: URLProtocol {
  private struct Stub {
    let statusCode: Int
    let body: Data
    let error: Error?
  }

  private nonisolated(unsafe) static var stub: Stub?
  private nonisolated(unsafe) static var capturedRequests: [URLRequest] = []
  private static let lock = NSLock()

  static func set(statusCode: Int, body: Data = Data()) {
    lock.withLock {
      stub = Stub(statusCode: statusCode, body: body, error: nil)
    }
  }

  static func setError(_ error: Error) {
    lock.withLock {
      stub = Stub(statusCode: 0, body: Data(), error: error)
    }
  }

  static func reset() {
    lock.withLock {
      stub = nil
      capturedRequests = []
    }
  }

  static var recordedRequests: [URLRequest] {
    lock.withLock { capturedRequests }
  }

  static func makeClient(baseURL: URL? = URL(string: "https://attendance.test")) -> NetworkClient {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [URLProtocolStub.self]
    return NetworkClient(session: Session(configuration: configuration), baseURL: baseURL)
  }

  override class func canInit(with _: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    let current = Self.lock.withLock { () -> Stub? in
      Self.capturedRequests.append(request)
      return Self.stub
    }

    guard let current else {
      client?.urlProtocol(self, didFailWithError: URLError(.unknown))
      return
    }

    if let error = current.error {
      client?.urlProtocol(self, didFailWithError: error)
      return
    }

    let response = HTTPURLResponse(
      url: request.url ?? URL(string: "https://attendance.test")!,
      statusCode: current.statusCode,
      httpVersion: "HTTP/1.1",
      headerFields: ["Content-Type": "application/json"]
    )!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    if !current.body.isEmpty {
      client?.urlProtocol(self, didLoad: current.body)
    }
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}
