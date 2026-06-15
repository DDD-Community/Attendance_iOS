//
//  APIHeader.swift
//  Foundations
//
//  Created by Wonji Suh  on 5/7/25.
//

import ComposableArchitecture
import Foundation

public struct APIHeader {
  public static let contentType = "Content-Type"
  public static let accessToken = "Authorization"
  public static let accept = "accept"

  @Dependency(\.tokenProvider) private static var tokenProvider

  public static var accessTokenKeyChain: String {
    get {
      let token = tokenProvider.accessToken() ?? ""
      return token
    }
    set { updateAccessToken(newValue) }
  }

  public static func updateAccessToken(_ token: String?) {
    guard let newToken = token, !newToken.isEmpty else { return }
    tokenProvider.saveAccessToken(newToken)
  }

  public init() {}
}

public extension APIHeader {
  internal static func baseHeaders(_ headers: [String: String]?) -> [String: String] {
    var baseHeaders = baseHeader
    if let headers = headers {
      baseHeaders.merge(headers) { $1 }
    }
    return baseHeaders
  }

  static var baseHeader: [String: String] {
    [
      contentType: APIHeaderManger.contentType,
      accessToken: "Bearer \(accessTokenKeyChain)",
      accept: APIHeaderManger.contentType
    ]
  }

  // TODO: 임시 토큰(운영진) — Vote API 연동 테스트용. 실제 토큰 연동 후 제거하고 baseHeader 사용
  static var voteManagerTempHeader: [String: String] {
    [
      contentType: APIHeaderManger.contentType,
      accessToken: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyNzgiLCJyb2xlIjoiTUFOQUdFUiIsImV4cCI6NDEwMjQ0NDgwMH0.k7iylOR-v0Sy0B004wn_iD-q4-r1-ccFcx4udPzccTk",
      accept: APIHeaderManger.contentType
    ]
  }

  // TODO: 임시 토큰(멤버) — Vote API 연동 테스트용. 실제 토큰 연동 후 제거하고 baseHeader 사용
  static var voteMemberTempHeader: [String: String] {
    [
      contentType: APIHeaderManger.contentType,
      accessToken: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyNzkiLCJyb2xlIjoiTUVNQkVSIiwiZXhwIjo0MTAyNDQ0ODAwfQ.jiLCmNMp-XVmWp_mzLWgEBZH5p_Jk96IKJHUmEvOgPc",
      accept: APIHeaderManger.contentType
    ]
  }

  static var notAccessTokenHeader: [String: String] {
    [
      contentType: APIHeaderManger.contentType,
      accept: APIHeaderManger.contentType
    ]
  }

  static var mutiPartbaseHeader: [String: String] {
    [
      contentType: APIHeaderManger.multipartContentType,
      accessToken: "Bearer \(accessTokenKeyChain)"
    ]
  }

  static var applebaseHeader: [String: String] {
    [
      contentType: APIHeaderManger.contentType,
      accept: APIHeaderManger.contentType
    ]
  }
}
