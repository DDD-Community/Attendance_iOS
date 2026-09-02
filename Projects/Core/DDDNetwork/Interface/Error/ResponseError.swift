//
//  ResponseError.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

/// 서버가 명시적으로 내려준 에러 응답.
/// 출석 서버는 실패를 HTTP status(4xx/5xx)로 알리고 바디에 `{ code, message }` 를 담아 준다.
/// 사람에게 보여줄 문구는 `message`, 분기는 `code` 로 한다.
public struct ResponseError: Error, Sendable, Equatable {
  /// HTTP status
  public let httpStatus: Int
  /// 서버 에러 코드 (예: "VOTE_NOT_FOUND"). 없을 수 있다.
  public let code: String?
  /// 서버 에러 메시지
  public let message: String?

  public init(
    httpStatus: Int,
    code: String? = nil,
    message: String? = nil
  ) {
    self.httpStatus = httpStatus
    self.code = code
    self.message = message
  }

  /// 인증 실패 — 토큰 갱신/재로그인 분기용.
  public var isUnauthorized: Bool {
    httpStatus == 401
  }

  /// 5xx 인프라성 에러 여부
  public var isServerError: Bool {
    (500 ..< 600).contains(httpStatus)
  }
}
