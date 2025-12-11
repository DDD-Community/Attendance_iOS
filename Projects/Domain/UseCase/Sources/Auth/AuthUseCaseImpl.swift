//
//  AuthUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Repository

import ComposableArchitecture
import WeaveDI

public struct AuthUseCaseImpl: AuthInterface {
  private let repository: AuthInterface

  public init(
    repository: AuthInterface
  ) {
    self.repository = repository
  }


  // MARK: - API로 통해서 로그인
  public func loginUser(
    email: String
  ) async throws -> LoginModel? {
    return try await repository
      .loginUser(
        email: email
      )
  }
}

extension AuthUseCaseImpl: DependencyKey {
  static public var liveValue: AuthInterface = {
    let authRepository = UnifiedDI.register(AuthInterface.self) {
      AuthRepositoryImpl()
    }
    return AuthUseCaseImpl(repository: authRepository)
  }()
}

public extension DependencyValues {
  var authUseCase: AuthInterface {
    get { self[AuthUseCaseImpl.self] }
    set { self[AuthUseCaseImpl.self] = newValue }
  }
}

