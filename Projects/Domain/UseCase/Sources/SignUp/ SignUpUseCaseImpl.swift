//
//  SignUpUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Entity

import WeaveDI

public protocol SignUpUseCaseInterface: Sendable {
  func registerUser(
    userSession: UserSession
  ) async throws -> SignUpUser
}

public struct SignUpUseCaseImpl: SignUpUseCaseInterface {
  @Dependency(\.signUpRepository) var repository

  public init() { }

  // MARK: - 회원가입 API
  public func registerUser(
    userSession: UserSession
  ) async throws -> SignUpUser {
    let isManager = userSession.userRole == .manager
    if !isManager, userSession.selectTeamId == nil {
      throw SignUpError.missingRequiredField("팀")
    }
    let input = SignUpUserInput(
      name: userSession.name,
      generationId: userSession.generationId,
      jobRole: userSession.selectPart,
      teamId: isManager ? nil : userSession.selectTeamId,
      managerRoles: isManager ? userSession.managing : nil,
      provider: userSession.provider,
      token: userSession.token,
      invitationCode: userSession.inviteCode
    )
    return try await repository.registerUser(input: input)
  }
}

extension SignUpUseCaseImpl: DependencyKey {
  static public var liveValue: SignUpUseCaseInterface = SignUpUseCaseImpl()
  static public var testValue: SignUpUseCaseInterface = SignUpUseCaseImpl()
  static public var previewValue: SignUpUseCaseInterface = liveValue
}

public extension DependencyValues {
  var signUpUseCase: SignUpUseCaseInterface {
    get { self[SignUpUseCaseImpl.self] }
    set { self[SignUpUseCaseImpl.self] = newValue  }
  }
}
