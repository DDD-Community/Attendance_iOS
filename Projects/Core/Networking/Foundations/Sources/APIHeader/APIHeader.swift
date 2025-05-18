//
//  APIHeader.swift
//  Foundations
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

import ComposableArchitecture
import Model


public struct APIHeader {

  public static let contentType   = "Content-Type"
  public static let accessToken   = "Authorization"
  public static let accept        = "accept"
  public static let xcsrftoken    = "X-CSRFTOKEN"

  // ← add `static` here
  @Shared(.inMemory("UserEntity"))
  static var userEntity: UserEntity = .init()

  private static var _accessTokenKeyChain: String {
    return  UserDefaults.standard.string(forKey: "ACCESS_TOKEN") ?? "" // Returns an empty string if nil
  }

  public static var accessTokenKeyChain: String {
    get { _accessTokenKeyChain }
    set { updateAccessToken(newValue) }
  }

  public static func updateAccessToken(_ token: String?) {
    guard let newToken = token, !newToken.isEmpty else { return }
    UserDefaults.standard.set(newToken, forKey: "ACCESS_TOKEN")
    self.$userEntity.withLock {  $0.accessToken = newToken }
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
      accessToken: accessTokenKeyChain,
    ]
  }

  public static var applebaseHeader: Dictionary<String, String> {
    [
      contentType: APIHeaderManger.contentType,
      accept: APIHeaderManger.contentType
    ]
  }
}
