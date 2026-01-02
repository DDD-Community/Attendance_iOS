//
//  AuthRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Entity

import Service
import WeaveDI
import Dependencies

@preconcurrency import AsyncMoya


final public class AuthRepositoryImpl: AuthInterface, @unchecked Sendable {
  @Dependency(\.keychainManager) private var keychainManager
  private let provider: MoyaProvider<AuthService>
  private let authProvider: MoyaProvider<AuthService>

  public init(
    provider: MoyaProvider<AuthService> = MoyaProvider<AuthService>.default,
    authProvider: MoyaProvider<AuthService> = MoyaProvider<AuthService>.authorized
  ) {
    self.provider = provider
    self.authProvider = authProvider
  }

  // MARK: - 로그인 API
  public func login(
    provider socialProvider: SocialType,
    token: String
  ) async throws -> LoginEntity {
    let dto: LoginResponseDTO = try await provider.request(
      .login(body: OAuthLoginRequest(provider: socialProvider.description, token: token))
     )
    return dto.toDomain()
  }


// MARK: - 토큰 재발급
  public func refresh() async throws -> AuthTokens {
    let refreshToken  = keychainManager.refreshToken() ?? ""
    let dto: TokenDTO = try await authProvider.request(.refresh(refreshToken: refreshToken))
    return dto.toDomain()
  }
}
