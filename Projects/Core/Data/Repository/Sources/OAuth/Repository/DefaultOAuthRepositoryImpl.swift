//
//  DefaultOAuthRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import AuthenticationServices

import DomainInterface
import Model


final public class DefaultOAuthRepositoryImpl: OAuthInterface {

  public init() {}

  public func handleAppleLogin(_ requestResult: Result<ASAuthorization, any Error>, nonce: String) async throws -> ASAuthorization {
    return try await withCheckedThrowingContinuation { continuation in
      switch requestResult {
      case .success(_):
        break
      case .failure(let error):
        continuation.resume(throwing: error)
      }
    }
  }

  public func appleLoginWithFireBase(
    withIDToken: String,
    rawNonce: String,
    fullName: ASAuthorizationAppleIDCredential
  ) async throws -> OAuthResponseModel? {
    return nil
  }

  public func googleLogin() async throws -> OAuthResponseModel? {
    return nil
  }
}
