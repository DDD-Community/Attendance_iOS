//
//  AttendanceListResponseDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/15/25.
//

import Foundation

public typealias AttendanceListResponseDTOModel = BaseResponseDTO<[AttendanceListResonseDTO]>

public struct AttendanceListResonseDTO: Decodable {
  let id: String
  let profileSummary: ProfileSummaryDTO
  let scheduleSummary: ScheduleSummaryDTO
  let updatedAt: String?
  let status: String?
  let method: String?
  let note: String?

  enum CodingKeys: String, CodingKey {
    case id
    case profileSummary = "profile_summary"
    case scheduleSummary = "schedule_summary"
    case updatedAt = "updated_at"
    case status
    case method
    case note
  }
}

// MARK: - ProfileSummary
public struct ProfileSummaryDTO: Decodable {
  let name: String
  let role: String?
  let team: String?
  let cohort: String?
  let crew: String?
  let responsibility: String?
  let inviteCodeID: String?
  
  enum CodingKeys: String, CodingKey {
    case name
    case role
    case team
    case cohort
    case crew
    case responsibility
    case inviteCodeID = "invite_code_id"
  }
}

// MARK: - ScheduleSummary
public struct ScheduleSummaryDTO: Decodable {
  let id: String?
  let title: String?
  let description: String?
  let startTime: String?
  let endTime: String?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case description
    case startTime = "start_time"
    case endTime = "end_time"
  }
}
