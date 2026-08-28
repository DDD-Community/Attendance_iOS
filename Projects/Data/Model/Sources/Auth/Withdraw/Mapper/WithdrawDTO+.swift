//
//  WithdrawDTO+.swift
//  Model
//
//  Created by DDD on 1/2/26.
//

import Foundation
import Entity

public extension WithdrawDTO {
  func toDomain(isSuccess: Bool) -> WithdrawEntity {
    WithdrawEntity(
      isSuccess: isSuccess,
      code: code,
      message: message,
      detail: detail
    )
  }
}
