//
//  AuthUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Entity

import WeaveDI

public struct AuthUseCaseImpl: AuthInterface {
  @Dependency(\.authRepository) var authRepository

  public init() {}

  // MARK: - API로 통해서 로그인
  public func loginUser(
    email: String
  ) async throws -> LoginModel? {
    return try await authRepository
      .loginUser(
        email: email
      )
  }

  public func login(
    provider: Entity.SocialType,
    token: String
  ) async throws -> Entity.LoginEntity {
    return try await authRepository.login(provider: provider, token: token)
  }
}

extension AuthUseCaseImpl: DependencyKey {
  static public var liveValue: AuthInterface =  AuthUseCaseImpl()
  static public var testValue:   AuthInterface =  AuthUseCaseImpl()
  static public var previewValue: AuthInterface = liveValue
}

public extension DependencyValues {
  var authUseCase: AuthInterface {
    get { self[AuthUseCaseImpl.self] }
    set { self[AuthUseCaseImpl.self] = newValue }
  }
}
