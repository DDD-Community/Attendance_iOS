//
//  KeychainStorage.swift
//  DDDStorage
//
//  Created by DDD on 9/1/26.
//

import DDDStorageInterface
import Foundation
import Security

struct KeychainStorage: SecureStorage {
  private let service: String

  init(service: String = "io.DDD.Attendance") {
    self.service = service
  }

  func save(_ value: String, for key: SecureStorageKey) throws {
    let data = Data(value.utf8)
    let status = SecItemUpdate(
      baseQuery(for: key) as CFDictionary,
      [kSecValueData as String: data] as CFDictionary
    )

    switch status {
    case errSecSuccess:
      return
    case errSecItemNotFound:
      try add(data, for: key)
    default:
      throw SecureStorageError.unexpectedStatus(status)
    }
  }

  func load(_ key: SecureStorageKey) throws -> String? {
    var query = baseQuery(for: key)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne

    var item: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    switch status {
    case errSecSuccess:
      guard let data = item as? Data else { return nil }
      guard let value = String(data: data, encoding: .utf8) else {
        throw SecureStorageError.invalidData
      }
      return value
    case errSecItemNotFound:
      return nil
    default:
      throw SecureStorageError.unexpectedStatus(status)
    }
  }

  func remove(_ key: SecureStorageKey) throws {
    let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw SecureStorageError.unexpectedStatus(status)
    }
  }

  func removeAll() throws {
    for key in SecureStorageKey.all {
      try remove(key)
    }
  }
}

private extension KeychainStorage {
  func baseQuery(for key: SecureStorageKey) -> [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key.rawValue
    ]
  }

  func add(_ data: Data, for key: SecureStorageKey) throws {
    var query = baseQuery(for: key)
    query[kSecValueData as String] = data
    query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw SecureStorageError.unexpectedStatus(status)
    }
  }
}
