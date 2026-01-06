//
//  AuthUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Entity

import WeaveDI
import ComposableArchitecture
import Foundation

public struct AuthUseCaseImpl: AuthInterface {
  @Dependency(\.authRepository) var authRepository
  @Shared(.appStorage("staffRole")) var staffRole: Staff?
  @Dependency(\.keychainManager) private var keychainManager: KeychainManaging

  public init() {}

  // MARK: - API로 통해서 로그인
  public func login(
    provider: Entity.SocialType,
    token: String
  ) async throws -> Entity.LoginEntity {
    let authResult =  try await authRepository.login(provider: provider, token: token)
    keychainManager.save(
      accessToken: authResult.token.accessToken,
      refreshToken: authResult.token.refreshToken
    )
    return authResult
  }

  public func refresh() async throws -> Entity.AuthTokens {
    return try await authRepository.refresh()
  }

  public func logout() async throws -> AuthExitEntity {
    let logoutResult = try await authRepository.logout()
    $staffRole.withLock { $0 = nil }
    self.keychainManager.clear()
    return logoutResult
  }

  public func withDraw(token: String) async throws -> WithdrawEntity {
    let withDrawResult = try await authRepository.withDraw(token: token)
    self.keychainManager.clear()
    return withDrawResult
  }

  public func updateSessionCredential(with tokens: AuthTokens) {
    authRepository.updateSessionCredential(with: tokens)
  }
}

extension AuthUseCaseImpl: DependencyKey {
  static public var liveValue = AuthUseCaseImpl()
  static public var testValue = AuthUseCaseImpl()
  static public var previewValue = AuthUseCaseImpl()
}

public extension DependencyValues {
  var authUseCase: AuthUseCaseImpl {
    get { self[AuthUseCaseImpl.self] }
    set { self[AuthUseCaseImpl.self] = newValue }
  }
}
