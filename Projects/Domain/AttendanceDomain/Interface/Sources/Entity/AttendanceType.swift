//
//  AttendanceType.swift
//  AttendanceDomainInterface
//
//  Created by DDD on 7/14/24.
//

import Foundation

public enum AttendanceType: String, Codable {
  case present = "present"
  case absent = "absent"
  case late = "late"
  case earlyLeave = "earlyLeave"
  case disease = "disease"
  case run = "run"
  case notAttendance
  case tbd = "tbd" // ✅ 추가
  
  // 안전한 디코딩 처리: 예상하지 못한 값은 .thd 로 처리
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try? container.decode(String.self)
    self = AttendanceType(rawValue: rawValue ?? "") ?? .tbd
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(self.rawValue)
  }
  
  public var desc: String {
    switch self {
    case .present: return "PRESENT"
    case .absent: return "ABSENT"
    case .late: return "LATE"
    case .earlyLeave: return "EARLY_LEAVE"
    case .disease: return "DISEASE"
    case .run: return "RUN"
    case .notAttendance: return "NOT_ATTENDANCE"
    case .tbd: return "THD"
    }
  }
  
  public var koreanDesc: String {
    switch self {
    case .present: return "출석"
    case .absent: return "결석"
    case .late: return "지각"
    case .earlyLeave: return "조퇴"
    case .disease: return "병결"
    case .run: return "탈주"
    case .notAttendance: return "미참여"
    case .tbd: return "대기"
    }
  }
  
  public var imageDesc: String {
    switch self {
    case .present: return "Present_icons"
    case .absent: return "Abesent_icons"
    case .late: return "Late_icons"
    case .earlyLeave: return "EarlyLeave_icons"
    case .disease: return "Disease_icons"
    case .run: return "Run_icons"
    case .notAttendance: return "None_icons"
    case .tbd: return "Thd_icons"
    }
  }
}
