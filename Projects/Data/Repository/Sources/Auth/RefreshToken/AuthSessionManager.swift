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

  let authenticator: AccessTokenAuthenticator
  let interceptor: AuthenticationInterceptor<AccessTokenAuthenticator>
  let session: Session

  private init(authenticator: AccessTokenAuthenticator = AccessTokenAuthenticator()) {
    self.authenticator = authenticator

    let initialCredential = AuthSessionManager.loadCredentialFromKeychain()
    self.interceptor = AuthenticationInterceptor(
      authenticator: authenticator,
      credential: initialCredential
    )
    self.session = Session(interceptor: interceptor)
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
  static func loadCredentialFromKeychain() -> AccessTokenCredential? {
    let keychainManager = UnifiedDI.resolve(KeychainManaging.self) ?? InMemoryKeychainManager()
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
