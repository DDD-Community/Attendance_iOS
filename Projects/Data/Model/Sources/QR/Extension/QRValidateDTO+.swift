//
//  QRValidateDTO+.swift
//  Model
//
//  Created by Wonji Suh  on 1/12/26.
//

import Foundation
import Entity

public extension QRValidateDTO {
  func toDomain(isSuccess: Bool) -> QRValidateEntity {
    QRValidateEntity(
      isSuccess: isSuccess,
      code: code,
      message: message,
      detail: detail
    )
  }
}
