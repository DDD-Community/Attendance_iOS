//
//  SignUpUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import DiContainer
import Model
import Repository

import ComposableArchitecture

public struct SignUpUseCaseImpl: SignUpInterface {

  private let repository: SignUpInterface

  public init(
    repository: SignUpInterface
  ) {
    self.repository = repository
  }

  // MARK: - 회원가입 API
  public func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpModel? {
    return try await repository.registerAccount(
      email: email,
      password: password
    )
  }

  // MARK: -초대코드 확인
  public func validateInviteCode(
    inviteCode: String
  ) async throws -> InviteCodeModel? {
    return try await repository.validateInviteCode(inviteCode: inviteCode)
  }

  // MARK: - 이메일 검증
  public func checkEmail(email: String) async throws -> CheckEmailModel? {
    return try await repository.checkEmail(email: email)
  }
}

extension DependencyContainer {
  var signUpUseCase: SignUpInterface? {
    resolve(SignUpInterface.self)
  }
}


extension SignUpUseCaseImpl: DependencyKey {
  static public var liveValue: SignUpInterface = {
    let repository = ContainerResgister(\.signUpUseCase).wrappedValue
    return SignUpUseCaseImpl(repository: repository)
  }()
}

public extension DependencyValues {
  var signUpUseCase: SignUpInterface {
    get { self[SignUpUseCaseImpl.self] }
    set { self[SignUpUseCaseImpl.self] = newValue  }
  }
}

public extension RegisterModule {
  var signUpUseCaseImplModoule: () -> Module {
    makeUseCaseWithRepository(
      SignUpInterface.self,
      repositoryProtocol: SignUpInterface.self,
      repositoryFallback: DefaultSignUpRepositoryImpl(),
      factory: { repo in
        SignUpUseCaseImpl(repository: repo)
      }
    )
  }

  var signUpRepositoryImplModoule: () -> Module {
    makeDependency(SignUpInterface.self) {
      SignUpRepositoryImpl()
    }
  }
}
