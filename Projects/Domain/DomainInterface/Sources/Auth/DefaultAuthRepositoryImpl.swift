//
//  DefaultAuthRepositoryImpl.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Moved from Repository module
//

import Foundation
import Model
import Entity

/// Auth Repository의 기본 구현체 (테스트/프리뷰용)
final public class DefaultAuthRepositoryImpl: AuthInterface {

  public init() {}

  public func loginUser(
    email: String
  ) async throws -> LoginModel? {
    return nil
  }

  public func login(provider: Entity.SocialType, token: String) async throws -> Entity.LoginEntity {
    return LoginEntity(name: "", isNewUser: false, provider: .google, token: AuthTokens(accessToken: "", refreshToken: ""))
  }
}
