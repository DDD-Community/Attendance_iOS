//
//  BaseUserProfileDTO.swift
//  Service
//
//  Created by DDD on 1/6/26.
//

import Foundation

/// SignUp과 EditProfile에서 공통으로 사용되는 사용자 프로필 기본 구조
public struct BaseUserProfileDTO: Encodable, Sendable {
  public let name: String
  public let generationId: Int
  public let jobRole: String
  public let teamId: Int?
  public let managerRoles: [String]?
  public let invitationCode: String

  public init(
    name: String,
    generationId: Int,
    jobRole: String,
    teamId: Int?,
    managerRoles: [String]?,
    invitationCode: String
  ) {
    self.name = name
    self.generationId = generationId
    self.jobRole = jobRole
    self.teamId = teamId
    self.managerRoles = managerRoles
    self.invitationCode = invitationCode
  }
}

/// 인증 관련 정보를 담는 구조체
public struct AuthenticationDTO: Encodable, Sendable {
  public let provider: String
  public let token: String
  public let oauthRefreshToken: String?

  public init(
    provider: String,
    token: String,
    oauthRefreshToken: String? = nil
  ) {
    self.provider = provider
    self.token = token
    self.oauthRefreshToken = oauthRefreshToken
  }
}
