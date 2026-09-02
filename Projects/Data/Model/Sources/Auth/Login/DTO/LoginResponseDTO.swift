//
//  LoginResponseDTO.swift
//  Model
//
//  Created by DDD on 12/29/25.
//

import Foundation

public struct LoginResponseDTO: Decodable, Sendable {
  let userId: Int?
  let name: String?
  let email: String?
  let oauthProvider: String?
  let message: String
  let isNewUser: Bool
  let accessToken: String?
  let refreshToken: String?
  let oauthRefreshToken: String?
  let role: String?
}
