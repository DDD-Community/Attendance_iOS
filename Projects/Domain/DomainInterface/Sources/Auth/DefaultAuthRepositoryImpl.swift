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

  public func login(provider: Entity.SocialType, token: String) async throws -> Entity.LoginEntity {
    return LoginEntity(
      name: "Mock User",
      isNewUser: false,
      provider: provider,
      token: AuthTokens(
        accessToken: "mock_access_token_\(UUID().uuidString)",
        refreshToken: "mock_refresh_token_\(UUID().uuidString)"
      )
    )
  }

  public func refresh() async throws -> Entity.AuthTokens {
    return AuthTokens(
      accessToken: "mock_refreshed_access_token_\(UUID().uuidString)",
      refreshToken: "mock_refreshed_refresh_token_\(UUID().uuidString)"
    )
  }

  public func withDraw(token: String) async throws -> WithdrawEntity {
    return WithdrawEntity(isSuccess: true)
  }
}
