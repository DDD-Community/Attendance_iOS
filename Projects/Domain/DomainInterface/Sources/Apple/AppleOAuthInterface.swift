//
//  AppleOAuthInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation
import AuthenticationServices

import Entity

import WeaveDI

public protocol AppleOAuthInterface: Sendable {
  func signIn() async throws -> AppleOAuthPayload
  func signInWithCredential(_ credential: ASAuthorizationAppleIDCredential, nonce: String) async throws -> AppleOAuthPayload
}

// MARK: - Dependencies
public struct AppleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue:  AppleOAuthInterface {
    UnifiedDI.resolve(AppleOAuthInterface.self) ?? MockAppleOAuthRepository()
  }
  public static var previewValue:  AppleOAuthInterface  {
    UnifiedDI.resolve(AppleOAuthInterface.self) ?? MockAppleOAuthRepository()
  }
  public static var testValue:  AppleOAuthInterface = MockAppleOAuthRepository()
}

public extension DependencyValues {
  var appleOAuthRepository:  AppleOAuthInterface {
    get { self[AppleOAuthRepositoryDependencyKey.self] }
    set { self[AppleOAuthRepositoryDependencyKey.self] = newValue }
  }
}
