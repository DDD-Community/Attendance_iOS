//
//  AuthRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/4/24.
//

import Model

import Service

import AsyncMoya
import FirebaseFirestore

@Observable
public class AuthRepository: AuthRepositoryProtocol {
  
  private let fireBaseDB = Firestore.firestore()
  
  fileprivate var provider = MoyaProvider<AuthService>(plugins: [MoyaLoggingPlugin()])
  
  public init() {}
  
  // MARK: - 회원가입한 유저 조회
  
  // MARK: - 로그인 API
  public func loginUser(
    email: String,
  ) async throws -> LoginDTOModel? {
    let loginModel = try await provider.requestAsync(
      .login(
        email: email), decodeTo: LoginModel.self)
    return loginModel.toLoginDTOModel()
  }
  
  // MARK: - 세션  시작시 jwtCheck API
  public func sessionCheckJWT(
    token: String
  ) async throws -> RefreshTokenDTOModel? {
    let sessionCheckModel = try await provider.requestAsync(.sessionToJwt(token: token), decodeTo: RefreshTokenModel.self)
    return sessionCheckModel.toRefreshDTOModel()
  }
}
