//
//  AuthUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/4/24.
//

import ComposableArchitecture
import DiContainer
import Model

public struct AuthUseCases: AuthUseCaseProtocol {
  private let repository: AuthRepositoryProtocol
  
  public init(
    repository: AuthRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  //MARK: - 유저 조회
  public func fetchUser(uid: String) async throws -> UserDTOMember? {
    try await repository.fetchUser(uid: uid)
  }
}


extension AuthUseCases: DependencyKey {
  static public var liveValue: AuthUseCases = {
    let authRepository = DependencyContainer.live.resolve(AuthRepositoryProtocol.self)
    ?? DefaultAuthRepository() // 기본값 사용
    return AuthUseCases(repository: authRepository)
  }()
}
