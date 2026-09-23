//
//  JWTDecoder.swift
//  DDDAuth
//
//  Created by DDD on 9/1/26.
//

import Foundation

/// 서명 검증이 아니라 access token의 선제 refresh 시각 계산에 필요한 `exp`만 읽는다.
enum JWTDecoder {
  /// JWT payload의 `exp` 값을 만료 시각으로 변환하고 형식이 잘못되면 nil을 반환한다.
  static func decodeExpiration(_ token: String) -> Date? {
    let segments = token.split(separator: ".")
    guard segments.count > 1 else { return nil }

    var payload = String(segments[1])
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    payload += String(repeating: "=", count: (4 - payload.count % 4) % 4)

    guard let data = Data(base64Encoded: payload),
          let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let expiration = object["exp"] as? TimeInterval
    else {
      return nil
    }
    return Date(timeIntervalSince1970: expiration)
  }
}
