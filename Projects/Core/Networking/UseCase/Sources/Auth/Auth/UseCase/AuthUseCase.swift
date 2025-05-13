//
//  AuthUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/4/24.
//

import DiContainer
import Model

import ComposableArchitecture

public struct AuthUseCase: AuthUseCaseProtocol {
  private let repository: AuthRepositoryProtocol
  
  public init(
    repository: AuthRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  // MARK: - 유저 조회
  
  public func fetchUser(uid: String) async throws -> UserDTOMember? {
    try await repository.fetchUser(uid: uid)
  }
}

extension DependencyContainer {
  var authUseCase: AuthRepositoryProtocol? {
    resolve(AuthRepositoryProtocol.self)
  }
}


extension AuthUseCase: DependencyKey {
  static public var liveValue: AuthUseCase = {
    let authRepository = ContainerResgister(\.authUseCase).wrappedValue
    return AuthUseCase(repository: authRepository)
  }()
}

public extension DependencyValues {
  var authUseCase: AuthUseCase {
    get { self[AuthUseCase.self] }
    set { self[AuthUseCase.self] = newValue }
  }
}

public extension RegisterModule {
  
  var authUseCaseModule: () -> Module {
    makeUseCaseWithRepository(
      AuthUseCaseProtocol.self,
      repositoryProtocol: AuthRepositoryProtocol.self,
      repositoryFallback: DefaultAuthRepository(),
      factory: { repo in
        AuthUseCase(repository: repo)
      }
    )
  }
  
  var authRepositoryModule: () -> Module {
    makeDependency(AuthRepositoryProtocol.self) {
      AuthRepository()
    }
  }
  
}
