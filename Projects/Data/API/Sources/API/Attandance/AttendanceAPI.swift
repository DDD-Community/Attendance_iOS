//
//  AttandanceAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation

public enum AttendanceAPI {
  case adminAttendanceCount(scheduleId: Int)
  case editAttendance(attendanceId: String)
  case fetchCount

  public var description: String {
    switch self {

    case .adminAttendanceCount(let id):
      return "/me/schedules/\(id)/attendances"

    case .editAttendance(let attendanceId):
      return "\(attendanceId)/"

    case .fetchCount:
      return "count/"
    }
  }
}
