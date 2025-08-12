//
//  ScheduleDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation


public typealias ScheduleDTOModel = BaseResponse<[ScheduleDTOResponseModel]>

public struct ScheduleDTOResponseModel: Decodable {
  let id, title, description: String?
  let startTime, endTime: String?
  let createdAt: String?
  let attendancesSummary: [AttendancesSummaryDTO]?

  enum CodingKeys: String, CodingKey {
    case id, title, description
    case startTime = "start_time"
    case endTime = "end_time"
    case createdAt = "created_at"
    case attendancesSummary = "attendances_summary"

  }
}

struct AttendancesSummaryDTO: Decodable {
  let profile: ProfileDTO?
  let status, updatedAt: String?
  let method, note: String?

  enum CodingKeys: String, CodingKey {
    case profile, status
    case updatedAt = "updated_at"
    case method, note
  }
}

struct ProfileDTO: Decodable {
  let id: String
  let userID: Int
  let name, role, team, cohort: String
  let responsibility: String

  enum CodingKeys: String, CodingKey {
    case id
    case userID = "user_id"
    case name, role, team, cohort, responsibility
  }
}
