//
//  DefaultAuthRepositoryImpl.swift
//  DomainInterface
//
//  Created by DDD on 7/23/25.
//  Moved from Repository module
//

import Foundation
import Entity

/// Auth Repository의 기본 구현체 (테스트/프리뷰용)
final public class DefaultAuthRepositoryImpl: AuthInterface {
  public init() {}

  public func login(provider: Entity.SocialType, token: String) async throws(AuthError) -> Entity.LoginEntity {
    return LoginEntity(
      name: "Mock User",
      isNewUser: false,
      provider: provider,
      token: AuthTokens(
        accessToken: "mock_access_token_\(UUID().uuidString)",
        refreshToken: "mock_refresh_token_\(UUID().uuidString)"
      ),
      role: .member
    )
  }

  public func refresh() async throws(AuthError) -> Entity.AuthTokens {
    return AuthTokens(
      accessToken: "mock_refreshed_access_token_\(UUID().uuidString)",
      refreshToken: "mock_refreshed_refresh_token_\(UUID().uuidString)"
    )
  }

  public func withDraw(token: String) async throws(AuthError) -> WithdrawEntity {
    return WithdrawEntity(isSuccess: true)
  }

  public func logout() async throws(AuthError) -> AuthExitEntity {
    // Mock 로그아웃 성공 응답
    return AuthExitEntity(
      code: "200",
      message: "로그아웃이 성공적으로 완료되었습니다.",
      detail: "사용자 세션이 종료되었습니다."
    )
  }

  public func updateSessionCredential(with tokens: AuthTokens) async {
    // Mock 구현체에서는 아무것도 하지 않음 (테스트/프리뷰용)
  }
}
