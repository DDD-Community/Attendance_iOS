//
//  KeychainManagerInterface.swift
//  DomainInterface
//
//  Created by DDD on 1/2/26.
//

import Foundation

import Dependencies

public protocol KeychainManaging: Sendable {
  func save(accessToken: String, refreshToken: String)
  func saveAccessToken(_ token: String)
  func saveRefreshToken(_ token: String)
  func accessToken() -> String?
  func refreshToken() -> String?
  func clear()
}

public enum KeychainManagerDependency: TestDependencyKey {

  public static var testValue: KeychainManaging {
    InMemoryKeychainManager()
  }

  public static var previewValue: KeychainManaging = testValue
}

public extension DependencyValues {
  var keychainManager: KeychainManaging {
    get { self[KeychainManagerDependency.self] }
    set { self[KeychainManagerDependency.self] = newValue }
  }
}

