//
//  DefaultMemoryKeychainManager.swift
//  DomainInterface
//
//  Created by DDD on 1/2/26.
//

import Foundation

public final class InMemoryKeychainManager: KeychainManaging, @unchecked Sendable {
  private var accessTokenStorage: String?
  private var refreshTokenStorage: String?

  public init() {}

  public func save(accessToken: String, refreshToken: String) {
    accessTokenStorage = accessToken
    refreshTokenStorage = refreshToken
  }

  public func saveAccessToken(_ token: String) {
    accessTokenStorage = token
  }

  public func saveRefreshToken(_ token: String) {
    refreshTokenStorage = token
  }

  public func accessToken() -> String? {
    accessTokenStorage
  }

  public func refreshToken() -> String? {
    refreshTokenStorage
  }

  public func clear() {
    accessTokenStorage = nil
    refreshTokenStorage = nil
  }
}
