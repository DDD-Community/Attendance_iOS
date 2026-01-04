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
import Moya

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

  // MARK: - 로그아웃
  public func logout() async throws -> AuthExitEntity {
    let dto: LogOutDTO = try await provider.request(.logout)
    return dto.toDomain()
  }

  // MARK: - 계정 삭제
  public func withDraw(token: String) async throws -> WithdrawEntity {
    let response = try await provider.requestResponse(.withdraw(token: token))
    let decoder = JSONDecoder()

    if (200...299).contains(response.statusCode) {
      if response.data.isEmpty {
        return WithdrawEntity(isSuccess: true)
      }
      if let successDTO = try? decoder.decode(WithdrawDTO.self, from: response.data) {
        return successDTO.toDomain(isSuccess: true)
      }
      return WithdrawEntity(isSuccess: true)
    }

    if let errorDTO = try? decoder.decode(WithdrawDTO.self, from: response.data) {
      return errorDTO.toDomain(isSuccess: false)
    }
    return WithdrawEntity(
      isSuccess: false,
      message: String(data: response.data, encoding: .utf8)
    )
  }

}
