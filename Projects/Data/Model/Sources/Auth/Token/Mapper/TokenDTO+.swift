//
//  TokenDTO+.swift
//  Model
//
//  Created by DDD on 1/2/26.
//

import Foundation
import Entity

public extension TokenDTO {
  func toDomain() -> AuthTokens {
    return AuthTokens(
      accessToken: self.accessToken,
      refreshToken: self.refreshToken
    )
  }
}
