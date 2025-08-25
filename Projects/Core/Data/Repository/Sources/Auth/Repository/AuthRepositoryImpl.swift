//
//  AuthRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

import Service

import AsyncMoya
import FirebaseFirestore


@Observable
public class AuthRepositoryImpl: AuthInterface {
  fileprivate var provider = MoyaProvider<AuthService>(plugins: [MoyaLoggingPlugin()])

  public init() {}

  // MARK: - 회원가입한 유저 조회

  // MARK: - 로그인 API
  public func loginUser(
    email: String,
  ) async throws -> LoginModel? {
    let loginModel = try await provider.requestAsync(
      .login(
        email: email), decodeTo: LoginDTOModel.self)
    return loginModel.toDomanl()
  }
}
