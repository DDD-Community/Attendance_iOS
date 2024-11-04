//
//  DefaultOAuthRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 10/30/24.
//

import Model
import ComposableArchitecture
import AuthenticationServices

final public class DefaultOAuthRepository: OAuthRepositoryProtocol {
 
  
  public init() {
    
  }
  
  public func handleAppleLogin(_ requestResult: Result<ASAuthorization, any Error>, nonce: String) async throws -> ASAuthorization {
    return try await withCheckedThrowingContinuation { continuation in
      switch requestResult {
      case .success(let request):
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
  ) async throws -> OAuthResponseDTOModel? {
    return nil
  }
  
  
  public func googleLogin() async throws -> OAuthResponseDTOModel? {
    return nil
  }
  
  
}
