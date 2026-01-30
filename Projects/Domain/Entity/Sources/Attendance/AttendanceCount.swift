//
//  AttendanceCount.swift
//  Entity
//
//  Created by Wonji Suh  on 1/11/26.
//

import Foundation

public struct AttendanceCount: Equatable {
  public let attendanceCount: Int
  public let lateCount: Int
  public let absentCount: Int

  public init(
    attendanceCount: Int,
    lateCount: Int,
    absentCount: Int
  ) {
    self.attendanceCount = attendanceCount
    self.lateCount = lateCount
    self.absentCount = absentCount
  }
}

// MARK: - Mock Data
public extension AttendanceCount {
  static func mockData() -> AttendanceCount {
    return AttendanceCount(
      attendanceCount: 18,
      lateCount: 2,
      absentCount: 0
    )
  }

  static func mockHighAttendanceData() -> AttendanceCount {
    return AttendanceCount(
      attendanceCount: 25,
      lateCount: 1,
      absentCount: 0
    )
  }

  static func mockLowAttendanceData() -> AttendanceCount {
    return AttendanceCount(
      attendanceCount: 12,
      lateCount: 5,
      absentCount: 3
    )
  }

  static func mockEmptyData() -> AttendanceCount {
    return AttendanceCount(
      attendanceCount: 0,
      lateCount: 0,
      absentCount: 0
    )
  }
}
