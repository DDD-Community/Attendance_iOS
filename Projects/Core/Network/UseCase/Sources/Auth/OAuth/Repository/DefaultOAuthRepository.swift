//
//  DefaultOAuthRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 10/30/24.
//

import AuthenticationServices

import Model

import ComposableArchitecture

final public class DefaultOAuthRepository: OAuthRepositoryProtocol {

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
