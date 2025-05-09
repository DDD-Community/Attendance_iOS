//
//  ScheduleResponse.swift
//  DDDAttendance
//
//  Created by eunpyo on 4/13/25.
//

import Foundation

public struct ScheduleResponse: Decodable {
  let id: String
  let title: String
  let description: String
  let startTime: String
  let endTime: String
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case description
    case startTime = "start_time"
    case endTime = "end_time"
    case createdAt = "created_at"
  }
}
