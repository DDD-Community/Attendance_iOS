//
//  SignUpRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import Combine

import DomainInterface
import Model
import Service

@preconcurrency import AsyncMoya

@Observable
final public class SignUpRepositoryImpl: SignUpInterface {


  private let provider: MoyaProvider<SignUpService>

  public init(
    provider: MoyaProvider<SignUpService> = MoyaProvider<SignUpService>.default
  ) {
    self.provider = provider
  }

  // Mark : -  API 회원가입
  public func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpModel? {
    let signUpModel: SignUpDTOModel  = try await provider.request(
      .registerAccount(
        email: email,
        password1: password,
        password2: password))
    return signUpModel.toDomain()
  }

  // Mark : - 초대 코드 검증
  public func validateInviteCode(
    inviteCode: String
  ) async throws -> InviteCodeModel? {
    let model: InviteCodeDTOModel  = try await provider.request(
      .verifyInviteCode(inviteCode: inviteCode))
    return model.toDomain()
  }

  // MARK: - 이메일 검증
  public func checkEmail(email: String) async throws -> CheckEmailModel? {
    let model: CheckEmailDTOModel = try await provider.request(.checkEmail(email: email))
    return model.toDomain()
  }
}
