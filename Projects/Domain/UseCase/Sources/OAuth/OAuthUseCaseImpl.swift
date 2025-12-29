//
//  OAuthUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import AuthenticationServices

import DomainInterface
import Entity

import WeaveDI

public struct OAuthUseCaseImpl: OAuthInterface {
  @Dependency(\.oAuthRepository) var repository

  public init() { }

  // MARK: - 애플 일반 로그인

  public func handleAppleLogin(
    _ requestResult: Result<ASAuthorization, any Error>,
    nonce: String) async throws -> ASAuthorization {
      try await repository
        .handleAppleLogin(
          requestResult,
          nonce: nonce
        )
    }

  // MARK: - firebase 애플 로그인

  public func appleLoginWithFireBase(
    withIDToken: String ,
    rawNonce: String,
    fullName: ASAuthorizationAppleIDCredential
  ) async throws -> OAuthResponseModel? {
    try await repository.appleLoginWithFireBase(
      withIDToken: withIDToken,
      rawNonce: rawNonce,
      fullName: fullName
    )
  }

  // MARK: - 구글 로그인

  public func googleLogin() async throws -> OAuthResponseModel? {
    try await repository.googleLogin()
  }
}

extension OAuthUseCaseImpl: DependencyKey {
  static public var liveValue: OAuthInterface =  OAuthUseCaseImpl()
  static public var testValue: OAuthInterface =  OAuthUseCaseImpl()
  static public var previewValue: OAuthInterface  = liveValue
}

public extension DependencyValues {
  var oAuthUseCase: OAuthInterface {
    get { self[OAuthUseCaseImpl.self] }
    set { self[OAuthUseCaseImpl.self] = newValue }
  }
}

