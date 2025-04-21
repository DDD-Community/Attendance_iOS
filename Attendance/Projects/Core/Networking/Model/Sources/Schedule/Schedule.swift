//
//  Schedule.swift
//  DDDAttendance
//
//  Created by eunpyo on 4/13/25.
//

import Foundation

public struct Schedule: Identifiable, Equatable {
  public let id: String
  public let month: Int
  public let day: Int
  public let title: String
  public let description: String
  public let status: AttendanceStatus
  
  public init(
    id: String,
    month: Int,
    day: Int,
    title: String,
    description: String,
    status: AttendanceStatus
  ) {
    self.id = id
    self.month = month
    self.day = day
    self.title = title
    self.description = description
    self.status = status
  }
  
  public static func ==(lhs: Schedule, rhs: Schedule) -> Bool {
    return lhs.id == rhs.id
  }
}

public extension Schedule {
  static let mock: [Schedule] = [
    .init(
      id: UUID().uuidString,
      month: 6,
      day: 11,
      title: "오리엔테이션",
      description: "커리큘럼에 대한 설명 문구 작성",
      status: .present
    ),
    .init(
      id: UUID().uuidString,
      month: 6,
      day: 22,
      title: "부스팅 데이 1",
      description: "커리큘럼에 대한 설명 문구 작성",
      status: .late
    ),
    .init(
      id: UUID().uuidString,
      month: 7,
      day: 06,
      title: "직군 모임 1",
      description: "커리큘럼에 대한 설명 문구 작성",
      status: .absent
    ),
    .init(
      id: UUID().uuidString,
      month: 7,
      day: 20,
      title: "오리엔테이션",
      description: "커리큘럼에 대한 설명 문구 작성",
      status: .tbd
    )
  ]
}
