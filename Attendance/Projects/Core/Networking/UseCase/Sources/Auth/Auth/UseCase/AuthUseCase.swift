//
//  AuthUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/4/24.
//

import ComposableArchitecture
import DiContainer
import Model

public struct AuthUseCase: AuthUseCaseProtocol {
  private let repository: AuthRepositoryProtocols
  
  public init(
    repository: AuthRepositoryProtocols
  ) {
    self.repository = repository
  }
  
  //MARK: - 유저 조회
  public func fetchUser(uid: String) async throws -> UserDTOMember? {
    try await repository.fetchUser(uid: uid)
  }
}


extension AuthUseCase: DependencyKey {
  static public var liveValue: AuthUseCase =  {
    let oAuthRepository = DependencyContainer.live.resolve(AuthRepositoryProtocols.self) ?? DefaultAuthRepository()
    return AuthUseCase(repository: oAuthRepository)
  }()
}
