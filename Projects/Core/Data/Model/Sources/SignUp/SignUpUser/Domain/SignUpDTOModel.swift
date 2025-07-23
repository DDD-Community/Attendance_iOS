//
//  SignUpDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation
// MARK: - Welcome
public struct SignUpDTOModel: Decodable, Equatable {
  let access, refresh: String?
  let user: UserDTO?
  
}

// MARK: - User
struct UserDTO: Decodable, Equatable {
  let pk: Int?
  let username, email: String?
  
  enum CodingKeys: String, CodingKey {
    case pk, username, email
  }
}
