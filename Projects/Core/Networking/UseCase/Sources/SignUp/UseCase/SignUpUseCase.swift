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
  
  // MARK: - 초대코드 확인
  
  public func validateInviteCode(
    code: String
  ) async throws -> InviteDTOModel? {
    try await repository.validateInviteCode(code: code)
  }
  
  // MARK: - 운영진 회원가입
  
  public func signUpCoreMember(member: Member) async throws -> CoreMemberDTOSignUp? {
    try await repository.signUpCoreMember(member: member)
  }
  
  // MARK: - 멤버 회원가입
  
  public func signUpMember(
    member: Member
  ) async throws -> MemberDTOSignUp? {
    return try await repository
      .signUpMember(
        member: member
      )
  }
  
  // Mark : - 회원가입 API
  public func registerAccount(
    userName: String,
    email: String,
    password: String
  ) async throws -> SignUpDTOModel? {
    return try await repository.registerAccount(
      userName: userName,
      email: email,
      password: password
    )
  }
  
  // Mark : - 초대코드 확인
  public func validateInviteCode(
    inviteCode: String
  ) async throws -> SignUPInviteDTOModel? {
    return try await repository.validateInviteCode(inviteCode: inviteCode)
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
