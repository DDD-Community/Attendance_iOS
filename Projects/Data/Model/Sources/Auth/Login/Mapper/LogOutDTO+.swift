//
//  LogOutDTO+.swift
//  Model
//
//  Created by DDD on 1/4/26.
//

import Foundation
import Entity

public extension LogOutDTO {
  func toDomain() -> AuthExitEntity {
    AuthExitEntity(
      code: code,
      message: message,
      detail: detail
    )
  }
}
