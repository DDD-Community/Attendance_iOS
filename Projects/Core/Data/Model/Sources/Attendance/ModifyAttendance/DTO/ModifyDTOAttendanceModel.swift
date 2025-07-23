//
//  ModifyDTOAttendanceModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public typealias ModifyDTOAttendanceModel = BaseResponse<ModifyDTOAttendanceResponseModel>

// MARK: - DataClass
public struct ModifyDTOAttendanceResponseModel: Decodable {
  let id: String?
  let profileSummary: ProfileSummaryDTO?
  let scheduleSummary: ScheduleSummaryDTO?
  let updatedAt, status, method, note: String?
  
  enum CodingKeys: String, CodingKey {
    case id
    case profileSummary = "profile_summary"
    case scheduleSummary = "schedule_summary"
    case updatedAt = "updated_at"
    case status, method, note
  }
}
