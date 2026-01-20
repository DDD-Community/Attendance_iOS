//
//  StaffManaging.swift
//  Entity
//
//  Created by Wonji Suh  on 12/31/25.
//

import Foundation

public enum StaffManaging: String, CaseIterable, Codable, Equatable {
  case teamManaging = "TEAM_MANAGING"
  case scheduleReminder = "SCHEDULE_REMINDER"
  case photo = "PHOTO"
  case locationRental = "LOCATION_RENTAL"
  case snsManagement = "SNS_MANAGEMENT"
  case attendanceCheck = "ATTENDANCE_CHECK"

  public var desc: String {
    switch self {
    case .teamManaging:     return "팀매니징"
    case .scheduleReminder: return "일정 리마인드"
    case .photo:            return "사진 촬영"
    case .locationRental:   return "장소 대관"
    case .snsManagement:    return "SNS 관리"
    case .attendanceCheck:  return "출석 체크"
    }
  }

  public var apiKey: String { rawValue }

  public static func from(apiKey: String) -> StaffManaging? {
    // 먼저 영어 rawValue로 매핑 시도
    if let staffManaging = StaffManaging(rawValue: apiKey.uppercased()) {
      return staffManaging
    }

    // 한국어 desc로 매핑 시도
    return StaffManaging.allCases.first { $0.desc == apiKey }
  }
}
