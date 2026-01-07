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
  @Dependency(\.authUseCase) var authUseCase
  @Dependency(\.keychainManager) private var keychainManager
  @Dependency(\.profileUseCase) private var profileUseCase

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
      teamId: userSession.selectTeamId,
      managerRoles: isManager ? userSession.managing : nil,
      provider: userSession.provider,
      token: userSession.accessToken,
      oauthRefreshToken: userSession.provider == .apple ? userSession.oauthRefreshToken : nil,
      invitationCode: userSession.inviteCode
    )

    let signUpUser = try await repository.registerUser(input: input)

    let loginEntity = try await authUseCase.login(
      provider: userSession.provider,
      token: userSession.provider == .apple ? userSession.accessToken : userSession.token
    )

    keychainManager.save(
      accessToken: loginEntity.token.accessToken,
      refreshToken: loginEntity.token.refreshToken
    )

    
    authUseCase.updateSessionCredential(with: loginEntity.token)

    print("keychain \(keychainManager.accessToken())")

    return signUpUser
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
