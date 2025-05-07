//
//  SignUpModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation
// MARK: - Welcome
public struct SignUpModel: Decodable {
  let access, refresh: String?
  let user: User?
  
}

// MARK: - User
struct User: Decodable {
  let pk: Int?
  let username, email, firstName, lastName: String?
  
  enum CodingKeys: String, CodingKey {
    case pk, username, email
    case firstName = "first_name"
    case lastName = "last_name"
  }
}
