//
//  EditAttendanceDTO+.swift
//  Model
//
//  Created by Wonji Suh  on 1/13/26.
//

import Foundation
import Entity

public extension EditAttendanceDTO {
  func toDomain(isSuccess: Bool) -> EditAttendance {
    EditAttendance(
      isSuccess: isSuccess,
      code: code,
      message: message,
      detail: detail
    )
  }
}
