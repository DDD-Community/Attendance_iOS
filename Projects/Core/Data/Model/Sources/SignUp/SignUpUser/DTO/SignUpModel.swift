//
//  SignUpModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/7/25.
//

import Foundation

public typealias SignUpModel = BaseResponseDTO<SignUpResponseModel>

public struct SignUpResponseModel: Equatable, Decodable {
  public let accessToken: String?
  public let refreshToken: String?
  public let user: SignUPUser?

  
  public init(
    accessToken: String,
    refreshToken: String,
    user: SignUPUser?
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.user = user
  }
}


public struct SignUPUser: Equatable, Decodable {
  public let username, email: String
  
  public init(
    username: String,
    email: String
  ) {
    self.username = username
    self.email = email
  }
}
