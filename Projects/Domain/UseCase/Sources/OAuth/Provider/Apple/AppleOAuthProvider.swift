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
@preconcurrency import Entity
import DomainInterface

public final class AppleOAuthProvider: AppleOAuthProviderInterface, @unchecked Sendable {
  @Dependency(\.appleOAuthRepository) private var appleRepository: AppleOAuthInterface

  public init() {}

  public func signInWithCredential(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> AppleOAuthPayload {
    // appleRepository.signInWithCredential 사용 (credential을 직접 처리)
    let payload = try await appleRepository.signInWithCredential(credential, nonce: nonce)
    Log.info("Apple sign-in completed through repository with credential")
    return payload
  }

  public func signIn() async throws -> AppleOAuthPayload {
    // Repository를 통해 Apple 로그인 처리
    let payload = try await appleRepository.signIn()
    Log.info("Apple sign-in completed through repository (direct)")
    return payload
  }

  private func formatDisplayName(_ components: PersonNameComponents?) -> String? {
    guard let components else { return nil }
    let formatter = PersonNameComponentsFormatter()
    let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }
}
