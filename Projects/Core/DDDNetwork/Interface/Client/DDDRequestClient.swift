//
//  DDDRequestClient.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 네트워크 요청 진입점.
///
/// 두 가지 선언 방식을 모두 받는다.
/// - 엔드포인트를 enum 으로 묶고 케이스마다 응답이 다를 때: `send(_:as:)`
///   `try await client.send(AuthService.login(body: req), as: LoginDTO.self)`
/// - 요청 하나를 타입으로 만들어 응답까지 고정할 때: `send(_:)`
///   `try await client.send(FetchProfileRequest(id: 3))`
public protocol DDDRequestClient: Sendable {
  /// 요청을 보내고 호출부가 지정한 타입으로 디코딩한다.
  /// 한 enum 이 케이스마다 다른 응답을 가질 때 쓴다.
  func send<R: DDDDataRequest, T: Decodable & Sendable>(
    _ request: R,
    as type: T.Type
  ) async throws(DDDNetworkError) -> T

  /// 요청 타입에 선언된 `Response` 로 디코딩한다.
  func send<R: DDDDataRequest>(_ request: R) async throws(DDDNetworkError) -> R.Response

  /// 상태 코드와 원시 바디를 호출부가 직접 해석해야 하는 요청에 사용한다.
  func sendResponse<R: DDDDataRequest>(_ request: R) async throws(DDDNetworkError) -> DDDHTTPResponse
}
