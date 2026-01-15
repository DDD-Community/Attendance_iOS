//
//  AccessTokenCredential.swift
//  Repository
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation
import Alamofire
import LogMacro

struct AccessTokenCredential: Sendable {
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
    // JWT 디코딩을 시도하되, 실패하면 기본 만료시간 사용 (24시간 후)
    let fallbackExpiration = Date().addingTimeInterval(24 * 60 * 60) // 24시간
    let expiration = decodeExpiration(from: accessToken) ?? {
      #logDebug("⚠️ JWT decoding failed, using fallback expiration: 24 hours from now")
      return fallbackExpiration
    }()

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
    guard components.count == 3 else {
      #logDebug("🚫 JWT decoding failed: Invalid JWT format (expected 3 parts, got \(components.count))")
      return nil
    }

    let payload = components[1]
    var base64 = payload
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let paddingLength = 4 - (base64.count % 4)
    if paddingLength < 4 {
      base64 += String(repeating: "=", count: paddingLength)
    }

    guard let data = Data(base64Encoded: base64) else {
      #logDebug("🚫 JWT decoding failed: Base64 decoding failed")
      return nil
    }

    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      #logDebug("🚫 JWT decoding failed: JSON parsing failed")
      return nil
    }

    guard let exp = json["exp"] as? TimeInterval else {
      #logDebug("🚫 JWT decoding failed: 'exp' claim not found or invalid type")
      #logDebug("🔍 Available keys in JWT payload: \(json.keys.joined(separator: ", "))")
      return nil
    }

    let expirationDate = Date(timeIntervalSince1970: exp)
    #logDebug("✅ JWT expiration decoded successfully: \(expirationDate)")
    #logDebug("🕐 Time until expiration: \(expirationDate.timeIntervalSinceNow / 3600) hours")

    return expirationDate
  }
}
