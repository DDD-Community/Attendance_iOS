//
//  AuthExitEntity.swift
//  Entity
//
//  Created by Wonji Suh  on 1/4/26.
//

import  Foundation

public struct AuthExitEntity: Equatable {
  public let code: String?
  public let message: String?
  public let detail: String?

  public init(
    code: String? = nil,
    message: String? = nil,
    detail: String? = nil
  ) {
    self.code = code
    self.message = message
    self.detail = detail
  }
}
