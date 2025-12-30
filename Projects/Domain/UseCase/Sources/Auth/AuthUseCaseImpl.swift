//
//  AuthUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Entity

import WeaveDI

public struct AuthUseCaseImpl: AuthInterface {
  @Dependency(\.authRepository) var authRepository

  public init() {}

  // MARK: - API로 통해서 로그인
  public func login(
    provider: Entity.SocialType,
    token: String
  ) async throws -> Entity.LoginEntity {
    return try await authRepository.login(provider: provider, token: token)
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
