//
//  AttandanceAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation

public enum AttendanceAPI {
  case adminAttendanceCount(scheduleId: Int)
  case fetchTeams
  case sessionAttendances(scheduleId: Int, teamId: Int)
  case status
  case editAttendance(attendanceId: Int)

  public var description: String {
    switch self {

    case .adminAttendanceCount(let id):
      return "/me/schedules/\(id)/attendances"

      case .fetchTeams:
        return "/me/generations/teams"

      case .sessionAttendances(let scheduleId, let teamId):
        return "/me/schedules/\(scheduleId)/teams/\(teamId)/attendances"

      case .status:
        return "status"

      case .editAttendance(let attendanceId):
        return "\(attendanceId)"
    }
  }
}
