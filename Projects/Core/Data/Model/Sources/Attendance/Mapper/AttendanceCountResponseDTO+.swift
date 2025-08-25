//
//  AttendanceCountResponseDTO+.swift
//  Model
//
//  Created by eunpyo on 5/18/25.
//

import Foundation

public extension AttendanceCountResponseDTO {
  func toDomain() -> AttendanceCountResponseModel {
    return .init(
      attendanceCount: attendanceCount,
      presentCount: presentCount,
      lateCount: lateCount,
      absentCount: absentCount,
      exceptionCount: exceptionCount,
      tbdCount: tbdCount
    )
  }
}
