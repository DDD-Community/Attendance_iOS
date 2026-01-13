//
//  AttendanceRequestDTO.swift
//  Service
//
//  Created by Wonji Suh  on 1/11/26.
//

import Foundation

public struct AttendanceRequestDTO: Equatable, Encodable {
  public let scheduleId: Int
  public let teamId: Int

  public init(
    scheduleId: Int,
    teamId: Int
  ) {
    self.scheduleId = scheduleId
    self.teamId = teamId
  }
}


public struct EditAttendanceRequestDTO: Equatable, Encodable {
  public let attendanceId: Int // URL path용 (encode 제외)
  public let status: String
  public let userId: String

  public init(
    attendanceId: Int,
    status: String,
    userId: String
  ) {
    self.attendanceId = attendanceId
    self.status = status
    self.userId = userId
  }

  // encode할 때 attendanceId는 제외
  private enum CodingKeys: String, CodingKey {
    case status
    case userId
  }
}
