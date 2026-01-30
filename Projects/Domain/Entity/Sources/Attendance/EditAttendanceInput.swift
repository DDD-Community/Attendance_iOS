//
//  EditAttendanceInput.swift
//  Entity
//
//  Created by Wonji Suh  on 1/13/26.
//

import Foundation

public struct EditAttendanceInput {
  public let attendanceId: Int?
  public let scheduleId: Int
  public let status: AttendanceStatus
  public let userId: String

  public init(
    attendanceId: Int? = nil,
    scheduleId: Int,
    status: AttendanceStatus,
    userId: String
  ) {
    self.attendanceId = attendanceId
    self.scheduleId = scheduleId
    self.status = status
    self.userId = userId
  }
}

// MARK: - Mock Data
public extension EditAttendanceInput {
  static func mockData() -> EditAttendanceInput {
    return EditAttendanceInput(
      attendanceId: 1,
      scheduleId: 5,
      status: .attended,
      userId: "user_001"
    )
  }

  static func mockAttendedInput() -> EditAttendanceInput {
    return EditAttendanceInput(
      attendanceId: 1,
      scheduleId: 5,
      status: .attended,
      userId: "user_001"
    )
  }

  static func mockLateInput() -> EditAttendanceInput {
    return EditAttendanceInput(
      attendanceId: 2,
      scheduleId: 5,
      status: .late,
      userId: "user_002"
    )
  }

  static func mockAbsentInput() -> EditAttendanceInput {
    return EditAttendanceInput(
      attendanceId: 3,
      scheduleId: 5,
      status: .absent,
      userId: "user_003"
    )
  }

  static func mockNewAttendanceInput() -> EditAttendanceInput {
    return EditAttendanceInput(
      attendanceId: nil,
      scheduleId: 6,
      status: .attended,
      userId: "user_006"
    )
  }
}
