//
//  GoogleOAuthProvider.swift
//  UseCase
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation
import Dependencies
import LogMacro
import Entity
import DomainInterface

public class GoogleOAuthProvider {
    public let socialType: SocialType = .google

    @Dependency(\.googleOAuthRepository) private var googleRepository

    public init() {}

    public func signInWithToken(
        token: String
    ) async throws -> String {
        Log.info("Starting Google OAuth flow")
        let payload = try await googleRepository.signIn()
        return payload.idToken
    }
}