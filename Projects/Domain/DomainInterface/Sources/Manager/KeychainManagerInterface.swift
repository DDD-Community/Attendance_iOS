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

/// liveValue 는 DDDStorage 의 SecureStorage 위에 선 ServiceAssembly.KeychainManager 가 등록한다.
/// 여기서는 테스트 더블만 제공한다 — 메모리 기반 구현이 프로덕션 경로로 새지 않게 한다.
public enum KeychainManagerDependency: TestDependencyKey {
  public static var testValue: KeychainManaging {
    MockKeychainManager()
  }

  public static var previewValue: KeychainManaging = testValue
}

public extension DependencyValues {
  var keychainManager: KeychainManaging {
    get { self[KeychainManagerDependency.self] }
    set { self[KeychainManagerDependency.self] = newValue }
  }
}
