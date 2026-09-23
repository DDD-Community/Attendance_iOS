//
//  KeychainClient.swift
//  DDDStorage
//
//  Created by DDD on 9/2/26.
//

import Foundation
import Security

/// KeychainStorage가 운영체제 Security API와 통신하는 내부 경계입니다.
/// 테스트에서는 entitlement가 필요 없는 메모리 구현으로 교체합니다.
protocol KeychainClient: Sendable {
  func update(_ data: Data, service: String, account: String) -> OSStatus
  func add(_ data: Data, service: String, account: String) -> OSStatus
  func load(service: String, account: String) -> KeychainLoadResult
  func delete(service: String, account: String) -> OSStatus
}

struct KeychainLoadResult: Sendable {
  let status: OSStatus
  let data: Data?
}

struct SystemKeychainClient: KeychainClient {
  func update(_ data: Data, service: String, account: String) -> OSStatus {
    return SecItemUpdate(
      baseQuery(service: service, account: account) as CFDictionary,
      [kSecValueData as String: data] as CFDictionary
    )
  }

  func add(_ data: Data, service: String, account: String) -> OSStatus {
    var query = baseQuery(service: service, account: account)
    query[kSecValueData as String] = data
    query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
    return SecItemAdd(query as CFDictionary, nil)
  }

  func load(service: String, account: String) -> KeychainLoadResult {
    var query = baseQuery(service: service, account: account)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne

    var item: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    return KeychainLoadResult(status: status, data: item as? Data)
  }

  func delete(service: String, account: String) -> OSStatus {
    return SecItemDelete(baseQuery(service: service, account: account) as CFDictionary)
  }
}

private extension SystemKeychainClient {
  func baseQuery(service: String, account: String) -> [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account
    ]
  }
}
