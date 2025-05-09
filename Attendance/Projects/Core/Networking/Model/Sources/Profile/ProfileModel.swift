//
//  ProfileModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias ProfileModel = BaseResponse<ProfileResponseModel>

public struct ProfileResponseModel: Decodable {
  let id, name, inviteCodeID, role: String
  let team: String
  let isStaff: Bool
  let createdAt, updatedAt: String
  
  enum CodingKeys: String, CodingKey {
    case id, name
    case inviteCodeID = "invite_code_id"
    case role, team
    case isStaff = "is_staff"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}

