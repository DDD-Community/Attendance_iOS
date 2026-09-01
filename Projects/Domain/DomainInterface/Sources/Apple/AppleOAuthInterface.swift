//
//  AppleOAuthInterface.swift
//  DomainInterface
//
//  Created by DDD on 12/29/25.
//

import Foundation

import Dependencies
import AuthenticationServices

import Entity


public protocol AppleOAuthInterface: Sendable {
  func signIn() async throws -> AppleOAuthPayload
  func signInWithCredential(_ credential: ASAuthorizationAppleIDCredential, nonce: String) async throws -> AppleOAuthPayload
}

// MARK: - Dependencies
public enum AppleOAuthRepositoryDependencyKey: TestDependencyKey {
  public static var previewValue:  AppleOAuthInterface  {
    MockAppleOAuthRepository()
  }
  public static var testValue:  AppleOAuthInterface = MockAppleOAuthRepository()
}

public extension DependencyValues {
  var appleOAuthRepository:  AppleOAuthInterface {
    get { self[AppleOAuthRepositoryDependencyKey.self] }
    set { self[AppleOAuthRepositoryDependencyKey.self] = newValue }
  }
}
