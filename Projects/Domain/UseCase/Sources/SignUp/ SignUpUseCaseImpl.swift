//
//     SignUpUseCaseImpl.swift
//  UseCase
//
//  Created by DDD on 7/23/25.
//

import DDDCoreLogger
import ComposableArchitecture
import DomainInterface
import Entity

public protocol SignUpUseCaseInterface: Sendable {
  func registerUser(userSession: UserSession) async throws(SignUpError) -> SignUpUser
}


public struct SignUpUseCaseImpl: SignUpUseCaseInterface {
  @Dependency(\.signUpRepository) var repository
  @Dependency(\.authUseCase) var authUseCase
  @Dependency(\.profileUseCase) private var profileUseCase

  public init() {}

  // MARK: - 회원가입 API

  public func registerUser(
    userSession: UserSession
  ) async throws(SignUpError) -> SignUpUser {
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
      token: userSession.provider == .apple ? userSession.accessToken : userSession.token,
      oauthRefreshToken: userSession.provider == .apple ? userSession.oauthRefreshToken : nil,
      invitationCode: userSession.inviteCode
    )

    // 진짜 회원가입(POST /users). 이 단계 실패만 "회원가입 실패"로 처리.
    let signUpUser = try await repository.registerUser(input: input)

    // 회원가입 이후 토큰 재발급은 best-effort: 실패해도 회원가입 자체는 성공이므로 에러로 막지 않음.
    let loginResult = await Result {
      try await authUseCase.login(
        provider: userSession.provider,
        token: userSession.provider == .apple ? userSession.accessToken : userSession.token
      )
    }

    switch loginResult {
    case .success:
      break

    case let .failure(error):
      DDDLogger.error("회원가입 후 토큰 재발급 실패(회원가입 자체는 성공): \(error)", category: .auth)
    }

    return signUpUser
  }
}

extension SignUpUseCaseImpl: DependencyKey {
  public static var liveValue: SignUpUseCaseInterface = SignUpUseCaseImpl()
  public static var testValue: SignUpUseCaseInterface = SignUpUseCaseImpl()
  public static var previewValue: SignUpUseCaseInterface = liveValue
}

public extension DependencyValues {
  var signUpUseCase: SignUpUseCaseInterface {
    get { self[SignUpUseCaseImpl.self] }
    set { self[SignUpUseCaseImpl.self] = newValue }
  }
}
