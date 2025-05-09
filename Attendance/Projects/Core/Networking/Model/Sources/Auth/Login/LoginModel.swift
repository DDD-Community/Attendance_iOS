//
//  LoginModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public struct LoginModel: Decodable {
  let access, refresh: String?
  let user: User?
  let accessExpiration, refreshExpiration: String?
  
  enum CodingKeys: String, CodingKey {
    case access, refresh, user
    case accessExpiration = "access_expiration"
    case refreshExpiration = "refresh_expiration"
  }
}
