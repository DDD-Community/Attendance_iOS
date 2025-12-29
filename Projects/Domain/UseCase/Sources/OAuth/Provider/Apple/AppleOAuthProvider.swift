//
//  AppleOAuthProvider.swift
//  UseCase
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation
import Dependencies
import LogMacro
import AuthenticationServices
import Entity
import DomainInterface

public class AppleOAuthProvider {
  public let socialType: SocialType = .apple

  public init() {}

  public func signInWithCredential(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> AppleOAuthPayload {
    guard let identityTokenData = credential.identityToken,
          let identityToken = String(data: identityTokenData, encoding: .utf8)
    else {
      throw AuthError.missingIDToken
    }

    let authorizationCode: String?
    if let authCodeData = credential.authorizationCode {
      authorizationCode = String(data: authCodeData, encoding: .utf8)
    } else {
      authorizationCode = nil
    }

    let displayName = formatDisplayName(credential.fullName)


    return AppleOAuthPayload(
      idToken: identityToken,
      authorizationCode: authorizationCode,
      displayName: displayName,
      nonce: nonce
    )
  }

  private func formatDisplayName(_ components: PersonNameComponents?) -> String? {
    guard let components else { return nil }
    let formatter = PersonNameComponentsFormatter()
    let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }
}
