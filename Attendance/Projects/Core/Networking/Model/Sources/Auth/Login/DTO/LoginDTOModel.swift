//
//  LoginDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias LoginDTOModel = BaseResponseDTO<LoginResponseDTOModel>

// MARK: - Welcome
public struct LoginResponseDTOModel: Codable, Equatable {
  public let accessToken, refreshToken: String
  public let user: UserDTO
  public let accessExpiration, refreshExpiration: String
  
  public init(
    accessToken: String,
    refreshToken: String,
    user: UserDTO,
    accessExpiration: String,
    refreshExpiration: String
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.user = user
    self.accessExpiration = accessExpiration
    self.refreshExpiration = refreshExpiration
  }
  
}
