//
//  Attendance.swift
//  Entity
//
//  Created by Wonji Suh  on 1/11/26.
//

import Foundation

public struct Attendance: Equatable {
   public let id: String
  public let userID, userName, userInfo: String
  public let status:AttendanceStatus

  public init(
    id: String,
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
