//
//  OAuthUseCase.swift
//  UseCase
//
//  Created by Wonji Suh  on 10/30/24.
//

import  Model
import ComposableArchitecture
import DiContainer
import AuthenticationServices

public struct OAuthUseCase: OAuthUseCaseProtocol {
  
  private let repository: OAuthRepositoryProtocol
  
  public init(
    repository: OAuthRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  //MARK: - 애플  일반  로그인
  public func handleAppleLogin(
    _ requestResult: Result<ASAuthorization, any Error>,
    nonce: String) async throws -> ASAuthorization {
      try await repository
        .handleAppleLogin(
          requestResult,
          nonce: nonce
        )
  }
  
  //MARK: - firebase 애플 로그인
  public func appleLoginWithFireBase(
    withIDToken: String ,
    rawNonce: String,
    fullName: ASAuthorizationAppleIDCredential
  ) async throws -> OAuthResponseDTOModel? {
    try await repository.appleLoginWithFireBase(
      withIDToken: withIDToken,
      rawNonce: rawNonce,
      fullName: fullName
    )
  }
  
  //MARK: - 구글 로그인
  public func googleLogin() async throws -> OAuthResponseDTOModel? {
    try await repository.googleLogin()
  }
  
  //MARK: - 유저 조회
  public func fetchUser(
    uid: String
  ) async throws -> UserDTOMember? {
    try await repository.fetchUser(uid: uid)
  }
}


extension OAuthUseCase: DependencyKey {
  static public var liveValue: OAuthUseCase =  {
    let oAuthRepository = DependencyContainer.live.resolve(OAuthRepositoryProtocol.self) ?? DefaultOAuthRepository()
    return OAuthUseCase(repository: oAuthRepository)
  }()
}

