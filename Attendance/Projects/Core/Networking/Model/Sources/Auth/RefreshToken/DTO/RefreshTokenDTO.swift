//
//  RefreshTokenDTO.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias RefreshTokenDTOModel = BaseResponseDTO<RefreshTokenDTPResponseModel>

public struct RefreshTokenDTPResponseModel: Codable,Equatable {
  public let refreshToken, accessToken: String
  public let user: UserDTO
  
  public init(
    refreshToken: String,
    accessToken: String,
    user: UserDTO
  ) {
    self.refreshToken = refreshToken
    self.accessToken = accessToken
    self.user = user
  }
  
}
