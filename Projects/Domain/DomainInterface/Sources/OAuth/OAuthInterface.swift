//
//  OAuthInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Updated for WeaveDI v4.0 - Protocol-based DI Registration
//

import Foundation
import AuthenticationServices
import WeaveDI

/// OAuth 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol OAuthInterface: Sendable {
  func handleAppleLogin(
    _ requestResult: Result<ASAuthorization, Error>,
    nonce: String
  ) async throws -> ASAuthorization
  func appleLoginWithFireBase(
    withIDToken: String ,
    rawNonce: String,
    fullName: ASAuthorizationAppleIDCredential
  ) async throws -> OAuthResponseModel?
  func googleLogin() async throws -> OAuthResponseModel?
}

/// OAuth Repository의 DependencyKey 구조체
public struct OAuthRepositoryDependency: DependencyKey {
  public static var liveValue: OAuthInterface {
    UnifiedDI.resolve(OAuthInterface.self) ?? DefaultOAuthRepositoryImpl()
  }

  public static var testValue: OAuthInterface {
    UnifiedDI.resolve(OAuthInterface.self) ?? DefaultOAuthRepositoryImpl()
  }

  public static var previewValue: OAuthInterface = liveValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var oAuthRepository: OAuthInterface {
    get { self[OAuthRepositoryDependency.self] }
    set { self[OAuthRepositoryDependency.self] = newValue }
  }
}
