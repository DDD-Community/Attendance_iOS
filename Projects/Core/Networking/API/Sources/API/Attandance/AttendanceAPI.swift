//
//  AttandanceAPI.swift
//  API
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation

public enum AttendanceAPI {
  case getAttandances
  case attendanceCount
  case editAttendance(attendanceId: String)
  case fetchCount

  public var attendanceDescription: String {
    switch self {
    case .getAttandances:
      return ""
      
    case .attendanceCount:
      return "count/"
      
    case .editAttendance(let attendanceId):
      return "\(attendanceId)/"

    case .fetchCount:
      return "count/"
    }
  }
}
