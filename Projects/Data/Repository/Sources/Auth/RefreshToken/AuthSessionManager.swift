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
    let credential = AccessTokenCredential.make(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken
    )

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
    let accessToken = keychainManager.accessToken()
    let refreshToken = keychainManager.refreshToken()

    guard
      let accessToken = accessToken,
      let refreshToken = refreshToken,
      !accessToken.isEmpty,
      !refreshToken.isEmpty
    else {
      return nil
    }

    return AccessTokenCredential.make(
      accessToken: accessToken,
      refreshToken: refreshToken
    )
  }
}
