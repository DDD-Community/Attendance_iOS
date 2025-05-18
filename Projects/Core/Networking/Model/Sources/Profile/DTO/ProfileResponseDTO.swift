//
//  ProfileResponseDTO.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public struct ProfileResponseDTO: Decodable {
  let id: String?
  let userID: Int?
  let name: String
  let inviteCodeID: String?
  let role: String?
  let team: String?
  let cohort: String?
  let isStaff: Bool?
  let createdAt: String?
  let updatedAt: String?

  enum CodingKeys: String, CodingKey {
    case id
    case userID = "user_id"
    case name
    case inviteCodeID = "invite_code_id"
    case role
    case team
    case cohort
    case isStaff = "is_staff"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}
