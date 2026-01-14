//
//  ScheduleModel.swift
//  Member
//
//  Created by 홍은표 on 1/15/26.
//

import Foundation

public struct ScheduleModel: Identifiable, Equatable {
  public let id: Int
  public let title: String
  public let description: String
  public let month: Int
  public let day: Int
  public let status: AttendanceStatus
  
  init(
    id: Int,
    title: String,
    description: String,
    month: Int,
    day: Int,
    status: AttendanceStatus
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.month = month
    self.day = day
    self.status = status
  }
}

public extension ScheduleModel {
  enum AttendanceStatus: String {
    case attended = "ATTENDED"
    case late = "LATE"
    case absent = "ABSENT"
    case none = "NONE"
  }
}
