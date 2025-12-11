//
//  QRValidateDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public typealias QRValidateDTOModel = BaseResponseDTO<QRValidateDTOResponseModel>

// MARK: - DataClass
public struct QRValidateDTOResponseModel: Decodable{
  let id: String
  let profileSummary: QRProfileDTOSummary
  let scheduleSummary: QRScheduleDTOSummary
  let updatedAt, status, method: String
  let note: String?

  enum CodingKeys: String, CodingKey {
    case id
    case profileSummary = "profile_summary"
    case scheduleSummary = "schedule_summary"
    case updatedAt = "updated_at"
    case status, method, note
  }
}

// MARK: - ProfileSummary
struct QRProfileDTOSummary: Decodable {
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

// MARK: - ScheduleSummary
struct QRScheduleDTOSummary: Decodable {
  let id, title, description: String
  let startTime, endTime: String

  enum CodingKeys: String, CodingKey {
    case id, title, description
    case startTime = "start_time"
    case endTime = "end_time"
  }
}
