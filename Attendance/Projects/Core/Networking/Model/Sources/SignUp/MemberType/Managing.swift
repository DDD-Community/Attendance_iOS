//
//  Managing.swift
//  Model
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

public enum Managing: String, CaseIterable, Codable {
    case accountiConsulting = "Accounti_Consulting"
    case photographer = "PhotoGrapher"
    case scheduleReminder = "Schedule_Reminder"
    case scheduleManagement = "Schedule_Management"
    case venueManagement = "Venue_Management"
    case snsManagement = "SNS_Management"
    case attendanceCheck = "Attendance_Check"
    case projectTeamManging = "Project_TeamManging"
    case notManging = "NotManging"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        if rawValue.trimmingCharacters(in: .whitespaces).isEmpty {
            self = .notManging
        } else {
            self = Managing(rawValue: rawValue) ?? .notManging
        }
    }

  public var mangingDesc: String {
        switch self {
        case .accountiConsulting:
            return "회계, MC"
        case .photographer:
            return "포토 그래퍼"
        case .scheduleManagement:
            return "일정 관리 (공지)"
        case .snsManagement:
            return "SNS 관리"
        case .attendanceCheck:
            return "출석 체크"
        case .projectTeamManging:
            return "팀매니징"
        case .scheduleReminder:
          return "일정 리마인드"
        case .venueManagement:
          return "장소 대관"
        case .notManging:
            return ""
       
        }
    }
  
  public static var mangingList: [Managing] {
    return [.projectTeamManging, .scheduleManagement, .photographer, .scheduleReminder, .venueManagement, .snsManagement, .attendanceCheck]
  }
}
