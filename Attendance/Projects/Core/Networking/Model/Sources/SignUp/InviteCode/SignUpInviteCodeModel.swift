//
//  SignUpInviteCodeModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

// MARK: - Welcome
public struct SignUpInviteCodeModel: Decodable {
  let code: Int?
  let message: String?
  let data: SignUpInviteCodeResponseModel?
}

// MARK: - DataClass
struct SignUpInviteCodeResponseModel: Decodable {
  let valid: Bool?
  let inviteCodeID, inviteType: String?
  let expireTime: String?
  let oneTimeUse: Bool?
  let error: String?
  
  enum CodingKeys: String, CodingKey {
    case valid
    case inviteCodeID = "invite_code_id"
    case inviteType = "invite_type"
    case expireTime = "expire_time"
    case oneTimeUse = "one_time_use"
    case error
  }
}
