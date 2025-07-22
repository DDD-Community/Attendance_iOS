//
//  QRValidate.swift
//  Model
//
//  Created by Wonji Suh  on 5/20/25.
//

import Foundation

public typealias QRValidateModel = BaseResponseDTO<QRValidateResponseModel>

// MARK: - DataClass
public struct QRValidateResponseModel: Decodable, Equatable {
  public let id: String?
  public let profileSummary: ProfileSummary?
  public let scheduleSummary: ScheduleSummary?
  public let updatedAt, status, method: String
  public let note: String?

  public   enum CodingKeys: String, CodingKey {
    case id
    case profileSummary = "profile_summary"
    case scheduleSummary = "schedule_summary"
    case updatedAt = "updated_at"
    case status, method, note
  }
}
