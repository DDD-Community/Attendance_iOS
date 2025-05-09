//
//  RefreshTokenModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias RefreshTokenModel = BaseResponse<RefreshTokenResponseModel>


public struct RefreshTokenResponseModel: Decodable {
  let refreshToken, accessToken: String?
  let user: User?
  
  enum CodingKeys: String, CodingKey {
    case refreshToken = "refresh_token"
    case accessToken = "access_token"
    case user
  }
}
