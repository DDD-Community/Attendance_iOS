//
//  LoginDTOModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias LoginDTOModel = BaseResponseDTO<LoginResponseDTOModel>

// MARK: - Welcome
public struct LoginResponseDTOModel: Decodable, Equatable {
  public let email: String
  public let id: Int
  public let accessToken, refreshToken: String
  
  
  public init(
    id: Int,
    email: String,
    accessToken: String,
    refreshToken: String,
  ) {
    self.id = id
    self.email = email
    self.accessToken = accessToken
    self.refreshToken = refreshToken
  }
}
