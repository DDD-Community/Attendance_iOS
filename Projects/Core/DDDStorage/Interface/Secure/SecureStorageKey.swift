//
//  SecureStorageKey.swift
//  DDDStorageInterface
//
//  Created by DDD on 9/1/26.
//

public struct SecureStorageKey: Hashable, Sendable {
  public let rawValue: String

  public init(_ rawValue: String) {
    self.rawValue = rawValue
  }
}

public extension SecureStorageKey {
  // 기존 KeychainManager 키를 유지해 업데이트 후에도 로그인 세션이 보존된다.
  static let accessToken = SecureStorageKey("ACCESS_TOKEN")
  static let refreshToken = SecureStorageKey("REFRESH_TOKEN")

  static let all: [SecureStorageKey] = [.accessToken, .refreshToken]
}
