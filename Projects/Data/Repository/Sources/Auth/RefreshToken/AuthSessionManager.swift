//
//  AuthSessionManager.swift
//  Repository
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation

import Alamofire
import DomainInterface
import Entity
import WeaveDI


final class AuthSessionManager {
  static let shared = AuthSessionManager()

  @Dependency(\.keychainManager) var keychainManager

  let authenticator: AccessTokenAuthenticator
  let interceptor: AuthenticationInterceptor<AccessTokenAuthenticator>
  let session: Session

  private init(authenticator: AccessTokenAuthenticator = AccessTokenAuthenticator()) {
    self.authenticator = authenticator

    // 먼저 nil로 초기화
    self.interceptor = AuthenticationInterceptor(
      authenticator: authenticator,
      credential: nil
    )
    self.session = Session(interceptor: interceptor)

    // 모든 프로퍼티 초기화 후 credential 설정
    setupInitialCredential()
  }

  func updateCredential(with tokens: AuthTokens) {
    guard let credential = AccessTokenCredential.make(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken
    ) else {
      interceptor.credential = nil
      return
    }

    interceptor.credential = credential
  }

  func clear() {
    interceptor.credential = nil
  }
}

private extension AuthSessionManager {
  func setupInitialCredential() {
    if let credential = loadCredentialFromKeychain() {
      interceptor.credential = credential
    }
  }

  func loadCredentialFromKeychain() -> AccessTokenCredential? {
    @Dependency(\.keychainManager) var keychainManager;
    guard
      let accessToken = keychainManager.accessToken(),
      let refreshToken = keychainManager.refreshToken()
    else {
      return nil
    }

    return AccessTokenCredential.make(
      accessToken: accessToken,
      refreshToken: refreshToken
    )
  }
}
