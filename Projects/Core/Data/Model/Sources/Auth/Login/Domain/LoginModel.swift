//
//  LoginModel.swift
//  Model
//
//  Created by Wonji Suh  on 5/9/25.
//

import Foundation

public typealias LoginModel = BaseResponseDTO<LoginResponseModel>

// MARK: - Welcome
public struct LoginResponseModel: Decodable, Equatable {
  public let email: String
  public let id: Int
  public let accessToken, refreshToken: String
  
}
