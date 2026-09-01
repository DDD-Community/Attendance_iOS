//
//  TokenRefresher.swift
//  DDDAuth
//
//  Created by DDD on 9/1/26.
//

import APIEndpoint
import DDDNetworkInterface
import Foundation

enum RefreshError: Error {
  /// 서버가 credential을 명시적으로 거부한 경우. 저장 세션을 종료해야 한다.
  case authFailure(DDDNetworkError)
  /// 연결 실패나 5xx 장애. 일시 장애일 수 있으므로 기존 세션을 유지한다.
  case networkFailure(DDDNetworkError)
}

/// 인증 인터셉터가 401 또는 만료 임박 시 호출하는 토큰 갱신기.
struct TokenRefresher: TokenRefreshing {
  /// 인증 헤더 없이 refresh endpoint를 호출하는 요청 클라이언트다.
  private let client: any DDDRequestClient
  /// 서버가 credential을 거부했을 때 인증 세션을 종료하는 콜백이다.
  private let onAuthFailure: @Sendable () async -> Void

  /// refresh 요청과 인증 실패 후처리를 한 갱신기로 조립한다.
  init(
    client: any DDDRequestClient,
    onAuthFailure: @escaping @Sendable () async -> Void
  ) {
    self.client = client
    self.onAuthFailure = onAuthFailure
  }

  /// 현재 refresh token을 새 credential 쌍으로 교환한다.
  func refresh(_ current: DDDCredential) async throws -> DDDCredential {
    do {
      let response = try await client.send(
        AuthRequest.refresh(refreshToken: current.refreshToken),
        as: RefreshTokenResponse.self
      )
      return DDDCredential(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: JWTDecoder.decodeExpiration(response.accessToken)
      )
    } catch {
      let classified = Self.classify(error)
      if case .authFailure = classified {
        await onAuthFailure()
      }
      throw classified
    }
  }

  /// 네트워크 오류를 세션 종료 여부에 따라 인증 실패와 일시 실패로 구분한다.
  private static func classify(_ error: DDDNetworkError) -> RefreshError {
    switch error {
    case let .response(response):
      // 5xx는 서버 장애, 그 외 응답 오류는 토큰 거부로 구분한다.
      return response.isServerError ? .networkFailure(error) : .authFailure(error)
    case .request, .transport, .decoding:
      return .networkFailure(error)
    }
  }
}

private struct RefreshTokenResponse: Decodable, Sendable {
  /// refresh 응답에서 받은 새 access token이다.
  let accessToken: String
  /// 다음 갱신에 사용할 새 refresh token이다.
  let refreshToken: String
}
