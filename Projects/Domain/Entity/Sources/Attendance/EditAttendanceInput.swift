//
//  EditAttendanceInput.swift
//  Entity
//
//  Created by Wonji Suh  on 1/13/26.
//

import Foundation

public struct EditAttendanceInput {
  public let attendanceId: Int
  public let status: AttendanceStatus
  public let userId: String

  public init(
    attendanceId: Int,
    status: AttendanceStatus,
    userId: String
  ) {
    self.attendanceId = attendanceId
    self.status = status
    self.userId = userId
  }
}
