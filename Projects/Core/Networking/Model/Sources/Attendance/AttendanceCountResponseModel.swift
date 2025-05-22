//
//  AttendanceCountResponseModel.swift
//  Model
//
//  Created by eunpyo on 5/18/25.
//

import Foundation

public struct AttendanceCountResponseModel: Equatable {
  public let attendanceCount: Int
  public let presentCount: Int
  public let lateCount: Int
  public let absentCount: Int
  public let exceptionCount: Int
  public let tbdCount: Int

  public init(
    attendanceCount: Int,
    presentCount: Int,
    lateCount: Int,
    absentCount: Int,
    exceptionCount: Int,
    tbdCount: Int
  ) {
    self.attendanceCount = attendanceCount
    self.presentCount = presentCount
    self.lateCount = lateCount
    self.absentCount = absentCount
    self.exceptionCount = exceptionCount
    self.tbdCount = tbdCount
  }
}
