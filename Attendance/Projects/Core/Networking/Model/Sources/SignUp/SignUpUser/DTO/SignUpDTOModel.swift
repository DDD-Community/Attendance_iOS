//
//  SignUpDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

public struct SignUpDTOModel: Equatable, Codable {
  public let data: SignUpResponseDTOModel
  
  public init(data: SignUpResponseDTOModel) {
    self.data = data
  }
  
}

public struct SignUpResponseDTOModel: Equatable, Codable {
  public let accessToken: String
  public let refreshToken: String
  public let user: UserDTO
  
  
  public init(
    accessToken: String,
    refreshToken: String,
    user: UserDTO
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.user = user
  }
}


public struct UserDTO: Equatable, Codable {
  public let username, email: String
  
  public init(
    username: String,
    email: String
  ) {
    self.username = username
    self.email = email
  }
}
