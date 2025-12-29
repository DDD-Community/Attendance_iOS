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
  ) async throws -> String {
    guard let identityTokenData = credential.identityToken,
          let identityToken = String(data: identityTokenData, encoding: .utf8)
    else {
      throw AuthError.missingIDToken
    }

    let displayName = formatDisplayName(credential.fullName)
    Log.info("Apple sign-in credential received for \(displayName ?? "unknown user")")
    Log.info("Apple sign-in succeeded")

    return identityToken
  }

  private func formatDisplayName(_ components: PersonNameComponents?) -> String? {
    guard let components else { return nil }
    let formatter = PersonNameComponentsFormatter()
    let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }
}
