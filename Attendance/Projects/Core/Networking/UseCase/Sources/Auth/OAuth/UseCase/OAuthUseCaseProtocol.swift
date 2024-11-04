//
//  OAuthUseCaseProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 10/30/24.
//

import Foundation
import AuthenticationServices
import Model

public protocol OAuthUseCaseProtocol {
  func handleAppleLogin(_ requestResult: Result<ASAuthorization, Error>, nonce: String) async throws -> ASAuthorization
  func appleLoginWithFireBase(withIDToken: String , rawNonce: String, fullName: ASAuthorizationAppleIDCredential) async throws -> OAuthResponseDTOModel?
  func googleLogin() async throws -> OAuthResponseDTOModel?
}
