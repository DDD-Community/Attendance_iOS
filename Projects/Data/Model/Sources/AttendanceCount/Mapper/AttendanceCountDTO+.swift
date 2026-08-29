//
//  AttendanceCountDTO+.swift
//  Model
//
//  Created by DDD on 1/11/26.
//

import Foundation
import Entity

public extension AttendanceCountDTO {
  func toDomain() -> AttendanceCount {
    return AttendanceCount(
      attendanceCount: self.totalAttended,
      lateCount: self.totalLate,
      absentCount: self.totalAbsent
    )
  }
}
