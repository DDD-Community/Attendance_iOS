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
  public static let xcsrftoken        = "X-CSRFTOKEN"
  
  // ← add `static` here
  @Shared(.inMemory("UserEntity"))
  static var userEntity: UserEntity = .init()
  
  private static var _accessTokenKeyChain: String {
    // now this compiles, because $userEntity is also static
    return self.$userEntity.withLock { $0.accessToken }
  }
  
  public static var accessTokenKeyChain: String {
    get { _accessTokenKeyChain }
    set { updateAccessToken(newValue) }
  }

  public static func updateAccessToken(_ token: String?) {
    guard let newToken = token, !newToken.isEmpty else { return }
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
      contentType : APIHeaderManger.shared.contentType,
      accessToken : accessTokenKeyChain,
      accept: APIHeaderManger.shared.contentType
    ]
  }
  
  public static var notAccessTokenHeader: Dictionary<String, String> {
    [
      contentType : APIHeaderManger.shared.contentType,
      xcsrftoken :APIHeaderManger.shared.csrf,
      //          accessToken : "Bearer \(accessTokenKeyChain ?? "")",
      accept: APIHeaderManger.shared.contentType
    ]
  }
  
  public static var mutiPartbaseHeader: Dictionary<String, String> {
    [
      contentType : APIHeaderManger.shared.multipartContentType,
      accessToken : accessTokenKeyChain,
    ]
  }
  
  public static var applebaseHeader: Dictionary<String, String> {
    [
      contentType : APIHeaderManger.shared.contentType,
      //            "Authorization": "Bearer \(_accessAppleTokenKeyChain)",
      accept: APIHeaderManger.shared.contentType
    ]
  }
  
}

