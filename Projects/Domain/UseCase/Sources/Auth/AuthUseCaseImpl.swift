//
//  AuthUseCaseImpl.swift
//  UseCase
//
//  Created by DDD on 7/23/25.
//

import DomainInterface
import Entity

import ComposableArchitecture
import Foundation

public struct AuthUseCaseImpl: AuthInterface {
  @Dependency(\.authRepository) var authRepository
  @Shared(.appStorage("staffRole")) var staffRole: Staff?
  @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty

  public init() {}

  // MARK: - API로 통해서 로그인
  public func login(
    provider: Entity.SocialType,
    token: String
  ) async throws(AuthError) -> Entity.LoginEntity {
    let authResult =  try await authRepository.login(provider: provider, token: token)
    $userSession.withLock {
      $0.oauthRefreshToken = authResult.token.oauthRefreshToken
    }
    return authResult
  }

  public func refresh() async throws(AuthError) -> Entity.AuthTokens {
    return try await authRepository.refresh()
  }

  public func logout() async throws(AuthError) -> AuthExitEntity {
    let logoutResult = try await authRepository.logout()
    $staffRole.withLock { $0 = nil }
    return logoutResult
  }

  public func withDraw(token: String) async throws(AuthError) -> WithdrawEntity {
    return try await authRepository.withDraw(token: token)
  }

  public func updateSessionCredential(with tokens: AuthTokens) async {
    await authRepository.updateSessionCredential(with: tokens)
  }
}

extension AuthUseCaseImpl: DependencyKey {
  public static var liveValue = AuthUseCaseImpl()
  public static var testValue = AuthUseCaseImpl()
  public static var previewValue = AuthUseCaseImpl()
}

public extension DependencyValues {
  var authUseCase: AuthUseCaseImpl {
    get { self[AuthUseCaseImpl.self] }
    set { self[AuthUseCaseImpl.self] = newValue }
  }
}
