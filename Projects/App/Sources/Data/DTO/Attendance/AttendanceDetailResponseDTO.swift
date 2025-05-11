//
//  AttendanceListResponse.swift
//  DDDAttendance
//
//  Created by eunpyo on 4/13/25.
//

import Foundation

public struct AttendanceDetailResponseDTO: Decodable {
  let id: String
  let user: Int
  let userId: Int
  let userName: String
  let schedule: String
  let scheduleTitle: String
  let status: AttendanceStatusResponse
  let updatedAt: String
  let method: AttendanceMethodResponse?
  let note: String?

  enum CodingKeys: String, CodingKey {
    case id
    case user
    case userId = "user_id"
    case userName = "user_name"
    case schedule
    case scheduleTitle = "schedule_title"
    case status
    case updatedAt = "updated_at"
    case method
    case note
  }
}
