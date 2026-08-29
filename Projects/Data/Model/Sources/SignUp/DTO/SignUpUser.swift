//
//  SignUpUser.swift
//  Model
//
//  Created by DDD on 1/1/26.
//
import Foundation

public struct SignUpUserDTO: Decodable {
  let userID: Int
  let name: String
  let email: String?
  let generation: String
  let team: String?
  let jobRole: String
  let managerRoles: [String]?

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case name, email, generation, team, jobRole, managerRoles
  }
}
