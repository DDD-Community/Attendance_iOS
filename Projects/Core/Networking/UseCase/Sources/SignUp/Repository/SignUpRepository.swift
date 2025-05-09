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
  ) async throws -> SignUpDTOModel? {
    let signUpModel = try await provider.requestAsync(
      .registerAccount(
        email: email,
        password1: password,
        password2: password),
      decodeTo: SignUpModel.self)
    return signUpModel.toSIgnUpDTOModel()
  }
  
  // Mark : - 초대 코드 검증
  public func validateInviteCode(
    inviteCode: String
  ) async throws -> InviteDTOModel? {
    let validateInviteCodeModel = try await provider.requestAsync(
      .verifyInviteCode(inviteCode: inviteCode), decodeTo: InviteCodeModel.self)
    return validateInviteCodeModel.toSignUpDTOInviteCodeModel()
  }
  
  // MARK: - 이메일 검증
  public func checkEmail(email: String) async throws -> CheckEmailDTO? {
    let checkEmailModel = try await provider.requestAsync(.checkEmail(email: email), decodeTo: CheckEmailModel.self)
    return checkEmailModel.toCheckEmailDTOModel()
  }
  
  // Mark : -  API 회원가입
  public func registerAccount(
    userName: String,
    email: String,
    password: String
  ) async throws -> SignUpDTOModel? {
    let signUpModel = try await provider.requestAsync(
      .registerAccount(
        email: email,
        password1: password,
        password2: password),
      decodeTo: SignUpModel.self)
    return signUpModel.toSIgnUpDTOModel()
  }
  
  // Mark : - 초대 코드 검증
  public func validateInviteCode(
    inviteCode: String
  ) async throws -> SignUPInviteDTOModel? {
    let validateInviteCodeModel = try await provider.requestAsync(
      .verifyInviteCode(inviteCode: inviteCode), decodeTo: SignUpInviteCodeModel.self)
    return validateInviteCodeModel.toSignUpDTOInviteCodeModel()
  }
  
  // MARK: - 이메일 검증
  public func checkEmail(email: String) async throws -> CheckEmailDTO? {
    let checkEmailModel = try await provider.requestAsync(.checkEmail(email: email), decodeTo: CheckEmailModel.self)
    return checkEmailModel.toCheckEmailDTOModel()
  }
}
