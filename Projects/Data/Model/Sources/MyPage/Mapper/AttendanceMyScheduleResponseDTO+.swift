//
//  AttendanceMyScheduleResponseDTO+.swift
//  Model
//
//  Created by DDD on 1/12/26.
//

import Foundation

import Entity

public extension AttendanceMyScheduleResponseDTO {
  func toDomain() -> AttendanceMyScheduleResponse {
    return .init(
      id: id,
      name: name,
      desc: desc,
      month: month,
      day: day,
      status: status
    )
  }
}
