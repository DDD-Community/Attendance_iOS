//
//  AuthRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

import DDDCoreLogger
import DDDAuthInterface
import DDDNetworkInterface
import DomainInterface
import Entity
import Foundation
import Model

import Dependencies
import APIEndpoint

public final class AuthRepositoryImpl: AuthInterface, @unchecked Sendable {
  @Dependency(\.keychainManager) private var keychainManager
  @Dependency(\.profileLocalDataSource) private var profileLocalDataSource
  @Dependency(\.scheduleLocalDataSource) private var scheduleLocalDataSource

  private let client: any DDDRequestClient
  private let authService: any AuthService

  public init(
    client: any DDDRequestClient,
    authService: any AuthService
  ) {
    self.client = client
    self.authService = authService
  }

  // MARK: - 로그인 API

  public func login(
    provider socialProvider: SocialType,
    token: String
  ) async throws -> LoginEntity {
    let dto = try await client.send(
      AuthRequest.login(
        body: OAuthLoginRequest(provider: socialProvider.description, token: token)
      ),
      as: LoginResponseDTO.self
    )
    let entity = dto.toDomain()
    await authService.signIn(
      accessToken: entity.token.accessToken,
      refreshToken: entity.token.refreshToken
    )
    return entity
  }

  // MARK: - 토큰 재발급

  public func refresh() async throws -> AuthTokens {
    let refreshToken = keychainManager.refreshToken() ?? ""

    do {
      let dto = try await client.send(
        AuthRequest.refresh(refreshToken: refreshToken),
        as: TokenDTO.self
      )
      let refreshData = dto.toDomain()
      return refreshData
    } catch {
      DDDLogger.debug("🔍 [AuthRepositoryImpl] Refresh failed: \(error)", category: .auth)

      if case let DDDNetworkError.response(responseError) = error,
         responseError.isUnauthorized {
        throw AuthError.refreshTokenExpired
      }

      throw error
    }
  }

  // MARK: - 로그아웃

  public func logout() async throws -> AuthExitEntity {
    let response = try await client.sendResponse(AuthRequest.logout)
    let decoder = JSONDecoder()

    if (200 ... 299).contains(response.statusCode) {
      await authService.signOut()
      try? await profileLocalDataSource.clear()
      try? await scheduleLocalDataSource.clear()
      if response.data.isEmpty {
        return AuthExitEntity()
      }
      if let successDTO = try? decoder.decode(LogOutDTO.self, from: response.data) {
        return successDTO.toDomain()
      }
      return AuthExitEntity()
    }

    if let errorDTO = try? decoder.decode(LogOutDTO.self, from: response.data) {
      return errorDTO.toDomain()
    }

    let errorMessage = String(data: response.data, encoding: .utf8)
    return AuthExitEntity(message: errorMessage)
  }

  // MARK: - 계정 삭제

  public func withDraw(token: String) async throws -> WithdrawEntity {
    let response = try await client.sendResponse(AuthRequest.withdraw(token: token))
    let decoder = JSONDecoder()

    if (200 ... 299).contains(response.statusCode) {
      await authService.signOut()
      try? await profileLocalDataSource.clear()
      try? await scheduleLocalDataSource.clear()
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

  // MARK: - 세션 Credential 업데이트

  public func updateSessionCredential(with tokens: AuthTokens) async {
    await authService.signIn(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken
    )
  }
}
