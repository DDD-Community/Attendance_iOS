//
//  ProfileDTO.swift
//  Model
//
//  Created by Wonji Suh  on 1/4/26.
//

import Foundation

public struct ProfileDTO: Decodable {
  let userID: Int
  let name: String
  let email: String?
  let generation: String
  let team: String?
  let jobRole: String
  let managerRoles: [String]

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case name, email, generation, team, jobRole, managerRoles
  }
}
