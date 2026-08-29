//
//  GoogleOAuthRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 12/29/25.
//

import Foundation
import UIKit

import DomainInterface
import Entity

import GoogleSignIn
import LogMacro

public final class GoogleOAuthRepositoryImpl: GoogleOAuthInterface, @unchecked Sendable {
    private let configuration: GoogleOAuthConfiguration

    public init(configuration: GoogleOAuthConfiguration = .current) {
        self.configuration = configuration
    }

    @MainActor
    public func signIn() async throws -> GoogleOAuthPayload {
        guard configuration.isValid else {
            throw AuthError.configurationMissing
        }
        guard let presenting = Self.topViewController() else {
            throw AuthError.missingPresentingController
        }
        let gidConfiguration = GIDConfiguration(
            clientID: configuration.clientID,
            serverClientID: configuration.serverClientID
        )
        GIDSignIn.sharedInstance.configuration = gidConfiguration

        do {
            let result = try await signInWithRetry(presenting: presenting)
            return try makePayload(from: result)
        } catch let error as NSError {
            throw mapSignInError(error)
        }
    }

    @MainActor
    private func signInWithRetry(
        presenting: UIViewController
    ) async throws -> GIDSignInResult {
        do {
            return try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        } catch let error as NSError where error.domain == "RBSServiceErrorDomain" && error.code == 1 {
            Log.error("RBSServiceErrorDomain detected, retrying Google sign-in...")
            try await Task.sleep(for: .seconds(0.5))
            return try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        }
    }

    private func makePayload(from result: GIDSignInResult) throws -> GoogleOAuthPayload {
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingIDToken
        }

        let payload = GoogleOAuthPayload(
            idToken: idToken,
            accessToken: result.user.refreshToken.tokenString,
            authorizationCode: result.serverAuthCode,
            displayName: result.user.profile?.name
        )

        Log.info("Google serverAuthCode present: \(payload.authorizationCode != nil ? "yes" : "no")")
        return payload
    }

    private func mapSignInError(_ error: NSError) -> Error {
        if error.domain == "com.google.GIDSignIn",
           error.code == GIDSignInError.canceled.rawValue {
            Log.info("Google sign-in cancelled by user.")
            return AuthError.userCancelled
        }

        Log.error("Google sign-in failed: \(error.localizedDescription)")
        return AuthError.unknownError(error.localizedDescription)
    }

    private static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
