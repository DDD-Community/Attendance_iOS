//
//  AccessTokenCredential.swift
//  Repository
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation
import Alamofire

struct AccessTokenCredential: AuthenticationCredential, Sendable {
  let accessToken: String
  let refreshToken: String
  let expiration: Date

  private let refreshLeadTime: TimeInterval = 5 * 60

  var requiresRefresh: Bool {
    Date().addingTimeInterval(refreshLeadTime) >= expiration
  }

  static func make(
    accessToken: String,
    refreshToken: String
  ) -> AccessTokenCredential {
    // JWT 디코딩을 시도하되, 실패하면 기본 만료시간 사용 (1시간 후)
    let expiration = decodeExpiration(from: accessToken) ?? Date().addingTimeInterval(3600)

    return AccessTokenCredential(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiration: expiration
    )
  }
}

private extension AccessTokenCredential {
  static func decodeExpiration(from token: String) -> Date? {
    let components = token.components(separatedBy: ".")
    guard components.count == 3 else { return nil }

    let payload = components[1]
    var base64 = payload
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let paddingLength = 4 - (base64.count % 4)
    if paddingLength < 4 {
      base64 += String(repeating: "=", count: paddingLength)
    }

    guard let data = Data(base64Encoded: base64) else { return nil }
    guard
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let exp = json["exp"] as? TimeInterval
    else {
      return nil
    }

    return Date(timeIntervalSince1970: exp)
  }
}
