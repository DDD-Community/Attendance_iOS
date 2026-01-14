//
//  AttendanceMyScheduleResponse.swift
//  Entity
//
//  Created by 홍은표 on 1/12/26.
//

import Foundation

public struct AttendanceMyScheduleResponse {
  public let id: Int
  public let name: String
  public let desc: String
  public let month: Int
  public let day: Int
  public let status: String
  
  public init(
    id: Int,
    name: String,
    desc: String,
    month: Int,
    day: Int,
    status: String
  ) {
    self.id = id
    self.name = name
    self.desc = desc
    self.month = month
    self.day = day
    self.status = status
  }
}
