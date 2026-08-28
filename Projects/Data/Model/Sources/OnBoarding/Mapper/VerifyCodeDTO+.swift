//
//  VerifyCodeDTO+.swift
//  Model
//
//  Created by DDD on 12/30/25.
//

import Foundation

import Entity

public extension VerifyCodeDTO {
  func toDomain() -> VerifyCodeEntity {
    return VerifyCodeEntity(
      generationID: self.generationID,
      type: Staff.from(apiKey: self.type) ?? .member
    )
  }
}
