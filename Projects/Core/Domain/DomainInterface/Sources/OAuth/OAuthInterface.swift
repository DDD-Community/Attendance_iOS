//
//  OAuthInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//

import Foundation
import AuthenticationServices

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
