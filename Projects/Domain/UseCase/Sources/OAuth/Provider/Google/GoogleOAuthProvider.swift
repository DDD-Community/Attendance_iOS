//
//  GoogleOAuthProvider.swift
//  UseCase
//
//  Created by DDD on 12/29/25.
//

import Foundation
import Dependencies
import DDDCoreLogger
@preconcurrency import Entity
import DomainInterface
import Sharing

public final class GoogleOAuthProvider: GoogleOAuthProviderInterface, @unchecked Sendable {
  @Dependency(\.googleOAuthRepository) private var googleRepository
  @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty
  public init() {}

  public func signInWithToken(
    token: String
  ) async throws(AuthError) -> String {
    DDDLogger.info("Starting Google OAuth flow", category: .auth)
    let payload = try await googleRepository.signIn()
    self.$userSession.withLock { $0.accessToken = payload.accessToken ?? "" }
    DDDLogger.debug("gooogle access: \(payload.accessToken ?? "none")", category: .auth)
    return payload.idToken
  }
}
