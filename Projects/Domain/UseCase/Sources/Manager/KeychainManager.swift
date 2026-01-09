//
//  KeychainManager.swift
//  UseCase
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation

import DomainInterface
import Security
import ComposableArchitecture
import WeaveDI

public final class KeychainManager: KeychainManaging, @unchecked Sendable {
  private let service: String

  private enum Key {
    static let accessToken = "ACCESS_TOKEN"
    static let refreshToken = "REFRESH_TOKEN"
  }

  public init(service: String = "io.dddstudy.attendance") {
    self.service = service
  }

  public func save(accessToken: String, refreshToken: String) {
    saveAccessToken(accessToken)
    saveRefreshToken(refreshToken)
  }

  public func saveAccessToken(_ token: String) {
    save(token, for: Key.accessToken)
  }

  public func saveRefreshToken(_ token: String) {
    save(token, for: Key.refreshToken)
  }

  public func accessToken() -> String? {
    read(for: Key.accessToken)
  }

  public func refreshToken() -> String? {
    read(for: Key.refreshToken)
  }

  public func clear() {
    delete(for: Key.accessToken)
    delete(for: Key.refreshToken)
  }

  private func save(_ value: String, for key: String) {
    let data = Data(value.utf8)
    let query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: key
    ]

    let attributes: [CFString: Any] = [
      kSecValueData: data
    ]

    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    if status == errSecItemNotFound {
      var addQuery = query
      addQuery[kSecValueData] = data
      _ = SecItemAdd(addQuery as CFDictionary, nil)
    }
  }

  private func read(for key: String) -> String? {
    let query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: key,
      kSecReturnData: true,
      kSecMatchLimit: kSecMatchLimitOne
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess, let data = result as? Data else {
      return nil
    }
    return String(data: data, encoding: .utf8)
  }

  private func delete(for key: String) {
    let query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: key
    ]
    SecItemDelete(query as CFDictionary)
  }
}

// MARK: - TCA Dependency

public struct KeychainManagerDependency: DependencyKey {
  public static var liveValue: KeychainManaging {
    UnifiedDI.resolve(KeychainManaging.self) ?? KeychainManager()
  }

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
