//
//  APIHeader.swift
//  Foundations
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation
import UseCase

public struct APIHeader {

  public static let contentType   = "Content-Type"
  public static let accessToken   = "Authorization"
  public static let accept        = "accept"

  private static let keychainManager = KeychainManager()

  public static var accessTokenKeyChain: String {
    get { keychainManager.accessToken() ?? "" }
    set { updateAccessToken(newValue) }
  }

  public static func updateAccessToken(_ token: String?) {
    guard let newToken = token, !newToken.isEmpty else { return }
    keychainManager.saveAccessToken(newToken)
  }

  public init() {}
}

extension APIHeader {
  static func baseHeaders(_ headers: [String: String]?) -> [String: String] {
    var baseHeaders = baseHeader
    if let headers = headers {
      baseHeaders.merge(headers) { $1 }
    }
    return baseHeaders
  }

  public static var baseHeader: Dictionary<String, String> {
    [
      contentType: APIHeaderManger.contentType,
      accessToken: "Bearer \(accessTokenKeyChain)",
      accept: APIHeaderManger.contentType
    ]
  }

  public static var notAccessTokenHeader: Dictionary<String, String> {
    [
      contentType: APIHeaderManger.contentType,
      accept: APIHeaderManger.contentType
    ]
  }

  public static var mutiPartbaseHeader: Dictionary<String, String> {
    [
      contentType: APIHeaderManger.multipartContentType,
      accessToken: "Bearer \(accessTokenKeyChain)",
    ]
  }

  public static var applebaseHeader: Dictionary<String, String> {
    [
      contentType: APIHeaderManger.contentType,
      accept: APIHeaderManger.contentType
    ]
  }
}
