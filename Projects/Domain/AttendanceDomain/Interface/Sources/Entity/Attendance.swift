//
//  Attendance.swift
//  Entity
//
//  Created by DDD on 1/11/26.
//

import Foundation

import ProfileDomainInterface

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
    let team = SelectTeams.from(name: String(teamPart))
    return team == .unknown ? nil : team
  }

  var selectPartEntity: SelectParts? {
    let parts = userInfo.split(separator: "/").map { String($0) }
    guard parts.count > 1 else { return nil }
    return SelectParts.from(apiKey: parts[1])
  }
}
