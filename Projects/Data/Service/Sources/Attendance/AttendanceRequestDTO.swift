//
//  AttendanceRequestDTO.swift
//  Service
//
//  Created by DDD on 1/11/26.
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
  public let attendanceId: String?
  public let status: String
  public let userId: String
  public let scheduleId: String

  public init(
    attendanceId: String?,
    status: String,
    userId: String,
    scheduleId: String
  ) {
    self.attendanceId = attendanceId
    self.status = status
    self.userId = userId
    self.scheduleId = scheduleId
  }

  // encode할 때 attendanceId는 제외
  private enum CodingKeys: String, CodingKey {
    case attendanceId
    case scheduleId
    case status
    case userId
  }
}
