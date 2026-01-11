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
