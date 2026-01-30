//
//  AttendanceStatus.swift
//  Entity
//
//  Created by Wonji Suh  on 1/11/26.
//

import Foundation

public enum AttendanceStatus: String, CaseIterable, Equatable, Identifiable {
  case attended = "ATTENDED"
  case late = "LATE"
  case absent = "ABSENT"

  public var id: String {
    rawValue
  }

  public var desc: String {
    switch self {
    case .attended:
      return "출석"
    case .late:
      return "지각"
    case .absent:
      return "결석"
    }
  }

  public var apiKey: String {
    rawValue
  }

  public static func from(apiKey: String) -> AttendanceStatus? {
    AttendanceStatus(rawValue: apiKey.uppercased())
  }
}

// MARK: - Mock Data
public extension AttendanceStatus {
  static func mockRandomStatus() -> AttendanceStatus {
    return AttendanceStatus.allCases.randomElement() ?? .attended
  }
}
