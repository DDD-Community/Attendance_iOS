//
//  AttendanceMyScheduleResponseDTO+.swift
//  MyPageDomain
//
//  Created by DDD on 1/12/26.
//

import Foundation

import MyPageDomainInterface

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
