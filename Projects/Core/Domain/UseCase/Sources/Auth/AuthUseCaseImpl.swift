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
import DiContainer

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

extension DependencyContainer {
  var authUseCase: AuthInterface? {
    resolve(AuthInterface.self)
  }
}


extension AuthUseCaseImpl: DependencyKey {
  static public var liveValue: AuthInterface = {
    let authRepository = ContainerResgister(\.authUseCase).wrappedValue
    return AuthUseCaseImpl(repository: authRepository)
  }()
}

public extension DependencyValues {
  var authUseCase: AuthInterface {
    get { self[AuthUseCaseImpl.self] }
    set { self[AuthUseCaseImpl.self] = newValue }
  }
}

public extension RegisterModule {

  var authUseCaseModule: () -> Module {
    makeUseCaseWithRepository(
      AuthInterface.self,
      repositoryProtocol: AuthInterface.self,
      repositoryFallback: DefaultAuthRepositoryImpl(),
      factory: { repo in
        AuthUseCaseImpl(repository: repo)
      }
    )
  }

  var authRepositoryModule: () -> Module {
    makeDependency(AuthInterface.self) {
      AuthRepositoryImpl()
    }
  }
}

