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

  public var description: String {
    switch self {

    case .adminAttendanceCount(let id):
      return "/me/schedules/\(id)/attendances"

      case .fetchTeams:
        return "/me/generations/teams"

    }
  }
}
