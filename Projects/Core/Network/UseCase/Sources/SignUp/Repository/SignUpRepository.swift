//
//  SignUpRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//

import Combine

import Model

import Service

import AsyncMoya
import Moya

@Observable
public class SignUpRepository: SignUpRepositoryProtocol {

  private let provider = MoyaProvider<SignUpService>(plugins: [MoyaLoggingPlugin()])

  public init() {}


  // Mark : -  API 회원가입
  public func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpModel? {
    let signUpModel = try await provider.requestAsync(
      .registerAccount(
        email: email,
        password1: password,
        password2: password),
      decodeTo: SignUpDTOModel.self)
    return signUpModel.toDomain()
  }

  // Mark : - 초대 코드 검증
  public func validateInviteCode(
    inviteCode: String
  ) async throws -> InviteCodeModel? {
    let model = try await provider.requestAsync(
      .verifyInviteCode(inviteCode: inviteCode), decodeTo: InviteCodeDTOModel.self)
    return model.toDomain()
  }

  // MARK: - 이메일 검증
  public func checkEmail(email: String) async throws -> CheckEmailModel? {
    let model = try await provider.requestAsync(.checkEmail(email: email), decodeTo: CheckEmailDTOModel.self)
    return model.toDomain()
  }
}
