//
//  SignUpUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//

import Model

import DiContainer

import ComposableArchitecture

public struct SignUpUseCase: SignUpUseCaseProtocol {
  
  private let repository: SignUpRepositoryProtocol
  
  public init(
    repository: SignUpRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  // MARK: - 회원가입 API
  public func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpDTOModel? {
    return try await repository.registerAccount(
      email: email,
      password: password
    )
  }
  
  // MARK: -초대코드 확인
  public func validateInviteCode(
    inviteCode: String
  ) async throws -> SignUPInviteDTOModel? {
    return try await repository.validateInviteCode(inviteCode: inviteCode)
  }
  
  // MARK: - 이메일 검증
  public func checkEmail(email: String) async throws -> CheckEmailDTO? {
    return try await repository.checkEmail(email: email)
  }
}

extension DependencyContainer {
  var signUpUseCase: SignUpRepositoryProtocol? {
    resolve(SignUpRepositoryProtocol.self)
  }
}


extension SignUpUseCase: DependencyKey {
  static public var liveValue: SignUpUseCase = {
    let signUpRepository = ContainerResgister(\.signUpUseCase).wrappedValue
    return SignUpUseCase(repository: signUpRepository)
  }()
}

public extension DependencyValues {
  var signUpUseCase: SignUpUseCase {
    get { self[SignUpUseCase.self] }
    set { self[SignUpUseCase.self] = newValue  }
  }
}

public extension RegisterModule {
  var signUpUseCaseModoule: () -> Module {
    makeUseCaseWithRepository(
      SignUpUseCaseProtocol.self,
      repositoryProtocol: SignUpRepositoryProtocol.self,
      repositoryFallback: DefaultSignUpRepository(),
      factory: { repo in
        SignUpUseCase(repository: repo)
      }
    )
  }
  
  var signUpRepositoryModoule: () -> Module {
    makeDependency(SignUpRepositoryProtocol.self) {
      SignUpRepository()
    }
  }
}
