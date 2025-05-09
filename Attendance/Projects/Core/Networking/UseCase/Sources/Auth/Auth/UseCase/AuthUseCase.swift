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
  
  // MARK: - API로 통해서 로그인
  public func loginUser(
    email: String,
    password: String
  ) async throws -> LoginDTOModel? {
    return try await repository
      .loginUser(
        email: email,
        password: password
      )
  }
  
  // MARK: - 세션 시작시 jwt check
  public func sessionCheckJWT(
    token: String
  ) async throws -> LoginDTOModel? {
    return try await repository
      .sessionCheckJWT(
        token: token
      )
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
