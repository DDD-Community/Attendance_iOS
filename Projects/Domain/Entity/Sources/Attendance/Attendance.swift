//
//  Attendance.swift
//  Entity
//
//  Created by Wonji Suh  on 1/11/26.
//

import Foundation

public struct Attendance: Equatable, Identifiable {
  public let id: Int?
  public let userID: String
  public let userName, userInfo: String
  public let status:AttendanceStatus
  
  public init(
    id: Int?,
    userID: String,
    userName: String,
    userInfo: String,
    status: AttendanceStatus
  ) {
    self.id = id
    self.userID = userID
    self.userName = userName
    self.userInfo = userInfo
    self.status = status
  }
}

public extension Attendance {
  var selectTeamEntity: SelectTeams? {
    guard let teamPart = userInfo.split(separator: "/").first else { return nil }
    let normalized = teamPart.replacingOccurrences(of: " ", with: "").uppercased()
    switch normalized {
    case "WEB1팀": return .web1
    case "WEB2팀": return .web2
    case "IOS1팀": return .ios1
    case "IOS2팀": return .ios2
    case "ANDROID1팀": return .and1
    case "ANDROID2팀": return .and2
    default: return nil
    }
  }

  var selectPartEntity: SelectParts? {
    let parts = userInfo.split(separator: "/").map { String($0) }
    guard parts.count > 1 else { return nil }
    return SelectParts.from(apiKey: parts[1])
  }
}

// MARK: - Mock Data
public extension Attendance {
  static func mockData() -> Attendance {
    return Attendance(
      id: 1,
      userID: "user_001",
      userName: "김철수",
      userInfo: "iOS 1팀/iOS",
      status: .attended
    )
  }

  static func mockAttendedData() -> Attendance {
    return Attendance(
      id: 1,
      userID: "user_001",
      userName: "김철수",
      userInfo: "iOS 1팀/iOS",
      status: .attended
    )
  }

  static func mockLateData() -> Attendance {
    return Attendance(
      id: 2,
      userID: "user_002",
      userName: "이영희",
      userInfo: "Android 1팀/Android",
      status: .late
    )
  }

  static func mockAbsentData() -> Attendance {
    return Attendance(
      id: 3,
      userID: "user_003",
      userName: "박민수",
      userInfo: "WEB 1팀/Frontend",
      status: .absent
    )
  }

  static func mockDataArray() -> [Attendance] {
    return [
      mockAttendedData(),
      mockLateData(),
      mockAbsentData(),
      Attendance(
        id: 4,
        userID: "user_004",
        userName: "최지은",
        userInfo: "iOS 2팀/iOS",
        status: .attended
      ),
      Attendance(
        id: 5,
        userID: "user_005",
        userName: "정우성",
        userInfo: "Android 2팀/Android",
        status: .late
      )
    ]
  }
}
