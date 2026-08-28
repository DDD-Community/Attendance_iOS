//
//  OAuthRequest.swift
//  Service
//
//  Created by DDD on 12/29/25.
//

import Foundation

public struct OAuthLoginRequest: Encodable {
  public let provider: String
  public let token: String

  public init(
    provider: String,
    token: String
  ) {
    self.provider = provider
    self.token = token
  }
}
