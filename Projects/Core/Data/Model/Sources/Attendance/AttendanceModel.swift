//
// AttendanceModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/10/25.
//

import Foundation

public typealias AttendanceModel = BaseResponse<AttendanceResoponseModel>

// MARK: - Datum
public struct AttendanceResoponseModel: Decodable {
  let id: String?
  let profile: Profile?
  let scheduleTitle, status, updatedAt: String?
  let method: String?
  let note: String?
  let userID: Int?
  let scheduleID: String?
  
  enum CodingKeys: String, CodingKey {
    case id, profile
    case scheduleTitle = "schedule_title"
    case status
    case updatedAt = "updated_at"
    case method, note
    case userID = "user_id"
    case scheduleID = "schedule_id"
  }
}

// MARK: - Profile
public  struct Profile: Decodable {
  let name: String
  let role, team, cohort, inviteCodeID: String?
  
  enum CodingKeys: String, CodingKey {
    case name, role, team, cohort
    case inviteCodeID = "invite_code_id"
  }
}
