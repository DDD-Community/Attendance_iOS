//
//  LoginEntity.swift
//  Entity
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation

public struct LoginEntity: Equatable {
  public let name: String
  public let provider: SocialType
  public let token: AuthTokens
  public let isNewUser: Bool
  public let role: Staff?

  public init(
    name: String,
    isNewUser: Bool,
    provider: SocialType,
    token: AuthTokens,
    role: Staff?
  ) {
    self.name = name
    self.isNewUser = isNewUser
    self.provider = provider
    self.token = token
    self.role = role
  }
}

// MARK: - Mock Data
public extension LoginEntity {
  static func mockData() -> LoginEntity {
    return LoginEntity(
      name: "김철수",
      isNewUser: false,
      provider: .google,
      token: AuthTokens.mockData(),
      role: .member
    )
  }

  static func mockGoogleUser() -> LoginEntity {
    return LoginEntity(
      name: "김철수",
      isNewUser: false,
      provider: .google,
      token: AuthTokens.mockGoogleTokens(),
      role: .member
    )
  }

  static func mockAppleUser() -> LoginEntity {
    return LoginEntity(
      name: "이영희",
      isNewUser: false,
      provider: .apple,
      token: AuthTokens.mockAppleTokens(),
      role: .manager
    )
  }

  static func mockNewUser() -> LoginEntity {
    return LoginEntity(
      name: "박민수",
      isNewUser: true,
      provider: .google,
      token: AuthTokens.mockData(),
      role: nil
    )
  }

  static func mockManagerUser() -> LoginEntity {
    return LoginEntity(
      name: "최지은",
      isNewUser: false,
      provider: .apple,
      token: AuthTokens.mockAppleTokens(),
      role: .manager
    )
  }
}
