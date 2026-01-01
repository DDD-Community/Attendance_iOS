//
//  SignUpUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

import WeaveDI

public struct SignUpUseCaseImpl: SignUpInterface {
  @Dependency(\.signUpRepository) var repository

  public init() { }

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

extension SignUpUseCaseImpl: DependencyKey {
  static public var liveValue: SignUpInterface = SignUpUseCaseImpl()
  static public var testValue: SignUpInterface = SignUpUseCaseImpl()
  static public var previewValue: SignUpInterface = liveValue
}

public extension DependencyValues {
  var signUpUseCase: SignUpInterface {
    get { self[SignUpUseCaseImpl.self] }
    set { self[SignUpUseCaseImpl.self] = newValue  }
  }
}

