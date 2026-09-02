//
//  KeychainManager.swift
//  ServiceAssembly
//
//  Created by DDD on 9/1/26.
//

import DDDStorageInterface
import DomainInterface

public final class KeychainManager: KeychainManaging, @unchecked Sendable {
  private let storage: any SecureStorage

  public init(storage: any SecureStorage) {
    self.storage = storage
  }

  public func save(accessToken: String, refreshToken: String) {
    saveAccessToken(accessToken)
    saveRefreshToken(refreshToken)
  }

  public func saveAccessToken(_ token: String) {
    try? storage.save(token, for: .accessToken)
  }

  public func saveRefreshToken(_ token: String) {
    try? storage.save(token, for: .refreshToken)
  }

  public func accessToken() -> String? {
    return try? storage.load(.accessToken)
  }

  public func refreshToken() -> String? {
    return try? storage.load(.refreshToken)
  }

  public func clear() {
    try? storage.removeAll()
  }
}
