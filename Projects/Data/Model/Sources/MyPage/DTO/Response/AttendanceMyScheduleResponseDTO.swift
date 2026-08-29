//
//  AttendanceMyScheduleResponseDTO.swift
//  Model
//
//  Created by DDD on 1/12/26.
//

import Foundation

public struct AttendanceMyScheduleResponseDTO: Decodable {
  public let id: Int
  public let name: String
  public let status: String
  public let desc: String
  public let month: Int
  public let day: Int
  
  public init(
    id: Int,
    name: String,
    status: String,
    desc: String,
    month: Int,
    day: Int
  ) {
    self.id = id
    self.name = name
    self.status = status
    self.desc = desc
    self.month = month
    self.day = day
  }
}
