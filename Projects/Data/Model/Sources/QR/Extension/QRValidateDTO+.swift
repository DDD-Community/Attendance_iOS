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
    // status 문자열을 AttendanceStatus로 변환
    let attendanceStatus: AttendanceStatus? = {
      guard let statusString = status else { return nil }
      return AttendanceStatus.from(apiKey: statusString)
    }()

    return QRValidateEntity(
      isSuccess: isSuccess,
      code: code,
      message: message,
      detail: detail,
      status: attendanceStatus
    )
  }
}
