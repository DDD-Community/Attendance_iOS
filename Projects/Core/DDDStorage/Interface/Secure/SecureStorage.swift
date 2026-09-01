//
//  SecureStorage.swift
//  DDDStorageInterface
//
//  Created by DDD on 9/1/26.
//

public protocol SecureStorage: Sendable {
  func save(_ value: String, for key: SecureStorageKey) throws(SecureStorageError)
  func load(_ key: SecureStorageKey) throws(SecureStorageError) -> String?
  func remove(_ key: SecureStorageKey) throws(SecureStorageError)
  func removeAll() throws(SecureStorageError)
}
