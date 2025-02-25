//
//  AttendanceType.swift
//  Model
//
//  Created by 서원지 on 7/14/24.
//

import Foundation

public enum AttendanceType: String, Codable {
  case present = "PRESENT"
  case absent = "ABSENT"
  case late = "LATE"
  case earlyLeave = "EARLY_LEAVE"
  case disease = "DISEASE"
  case run = "RUN"
  case notAttendance
  
  var desc: String {
    switch self {
    case .present:
      return "PRESENT"
    case .absent:
      return "ABSENT"
    case .late:
      return "LATE"
    case .earlyLeave:
      return "EARLY_LEAVE"
    case .disease:
      return "DISEASE"
    case .run:
      return "RUN"
    case .notAttendance:
      return "NONE"
    }
  }
  
  public var koreanDesc: String {
    switch self {
    case .present:
      return "출석"
    case .absent:
      return "결석"
    case .late:
      return "지각"
    case .run:
      return "탈주"
    default:
      return ""
    }
  }
  
  public var imageDesc: String {
    switch self {
    case .present:
      return "Present_icons"
    case .absent:
      return "Abesent_icons"
    case .late:
      return "Late_icons"
    default:
      return "Present_icons"
    }
  }
}
