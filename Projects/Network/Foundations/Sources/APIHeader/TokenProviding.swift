//
//  TokenProviding.swift
//  Foundations
//
//  Created by DDD on 1/2/26.
//

import Foundation

import Dependencies

public protocol TokenProviding: Sendable {
  func accessToken() -> String?
  func saveAccessToken(_ token: String)
}

/// 구현(liveValue)은 KeychainTokenProvider 를 소유한 Repository 모듈에서 등록한다.
public enum TokenProviderKey: TestDependencyKey {
  public static var testValue: TokenProviding {
    InMemoryTokenProvider()
  }
}

public extension DependencyValues {
  var tokenProvider: TokenProviding {
    get { self[TokenProviderKey.self] }
    set { self[TokenProviderKey.self] = newValue }
  }
}

public final class InMemoryTokenProvider: TokenProviding, @unchecked Sendable {
  private var storage: String?
  private let lock = NSLock()

  public init() {}

  public func accessToken() -> String? {
    lock.lock()
    defer { lock.unlock() }
    return storage
  }

  public func saveAccessToken(_ token: String) {
    lock.lock()
    storage = token
    lock.unlock()
  }
}
