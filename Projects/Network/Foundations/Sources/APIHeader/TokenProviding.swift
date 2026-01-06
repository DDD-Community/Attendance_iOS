//
//  TokenProviding.swift
//  Foundations
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation

import Dependencies
import WeaveDI

public protocol TokenProviding: Sendable {
  func accessToken() -> String?
  func saveAccessToken(_ token: String)
}

private enum TokenProviderKey: DependencyKey {
  static var liveValue: TokenProviding {
    UnifiedDI.resolve(TokenProviding.self) ?? InMemoryTokenProvider()
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
