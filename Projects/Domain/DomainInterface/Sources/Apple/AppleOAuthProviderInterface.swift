//
//  AppleOAuthProviderInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation
import AuthenticationServices
import WeaveDI
import Entity

/// Apple OAuth Provider Interface 프로토콜
public protocol AppleOAuthProviderInterface: Sendable {
  func signInWithCredential(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> AppleOAuthPayload

  func signIn() async throws -> AppleOAuthPayload
}

/// Apple OAuth Provider의 DependencyKey 구조체
public struct AppleOAuthProviderDependency: DependencyKey {
  public static var liveValue: AppleOAuthProviderInterface {
    UnifiedDI.resolve(AppleOAuthProviderInterface.self) ?? MockAppleOAuthProvider()
  }

  public static var testValue: AppleOAuthProviderInterface {
    UnifiedDI.resolve(AppleOAuthProviderInterface.self) ?? MockAppleOAuthProvider()
  }

  public static var previewValue: AppleOAuthProviderInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var appleOAuthProvider: AppleOAuthProviderInterface {
    get { self[AppleOAuthProviderDependency.self] }
    set { self[AppleOAuthProviderDependency.self] = newValue }
  }
}

/// 테스트용 Mock 구현체
public struct MockAppleOAuthProvider: AppleOAuthProviderInterface {
  public init() {}

  public func signInWithCredential(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> AppleOAuthPayload {
    return AppleOAuthPayload(
      idToken: "mock_id_token",
      authorizationCode: "mock_auth_code",
      displayName: "Mock User",
      nonce: nonce
    )
  }

  public func signIn() async throws -> AppleOAuthPayload {
    return AppleOAuthPayload(
      idToken: "mock_id_token",
      authorizationCode: "mock_auth_code",
      displayName: "Mock User",
      nonce: "mock_nonce"
    )
  }
}
