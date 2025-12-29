//
//  AppleOAuthRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 12/29/25.
//

import Foundation
import AuthenticationServices

import DomainInterface
import Entity

import LogMacro
import WeaveDI

#if canImport(UIKit)
import UIKit
#endif

public final class AppleOAuthRepositoryImpl: NSObject, AppleOAuthInterface {
  private let logger = LogMacro.Log.self
  @Dependency(\.appleManger) var appleLoginManger

  private var currentNonce: String?
  private var signInContinuation: CheckedContinuation<AppleOAuthPayload, Error>?

  public override init() {

  }
  @MainActor
  public func signIn() async throws -> AppleOAuthPayload {
    return try await withCheckedThrowingContinuation { continuation in
      self.signInContinuation = continuation

      let request = ASAuthorizationAppleIDProvider().createRequest()
      let nonce = appleLoginManger.prepare(request)
      self.currentNonce = nonce

      let controller = ASAuthorizationController(authorizationRequests: [request])
      controller.delegate = self
      controller.presentationContextProvider = self
      controller.performRequests()
    }
  }

  private func formatDisplayName(_ components: PersonNameComponents?) -> String? {
    guard let components else { return nil }
    let formatter = PersonNameComponentsFormatter()
    let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleOAuthRepositoryImpl: ASAuthorizationControllerDelegate {
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
      signInContinuation?.resume(throwing: AuthError.invalidCredential("Invalid credential type"))
      signInContinuation = nil
      return
    }

    guard let nonce = currentNonce else {
      signInContinuation?.resume(throwing: AuthError.missingIDToken)
      signInContinuation = nil
      return
    }

    guard let identityTokenData = credential.identityToken,
          let identityToken = String(data: identityTokenData, encoding: .utf8) else {
      signInContinuation?.resume(throwing: AuthError.missingIDToken)
      signInContinuation = nil
      return
    }

    let displayName = formatDisplayName(credential.fullName)
    let authorizationCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }

    let payload = AppleOAuthPayload(
      idToken: identityToken,
      authorizationCode: authorizationCode,
      displayName: displayName,
      nonce: nonce
    )

    logger.info("Apple Sign In successful for user: \(displayName ?? "unknown")")
    signInContinuation?.resume(returning: payload)
    signInContinuation = nil
    currentNonce = nil
  }

  public func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    let nsError = error as NSError

    if nsError.code == ASAuthorizationError.canceled.rawValue {
      signInContinuation?.resume(throwing: AuthError.userCancelled)
    } else {
      logger.error("Apple Sign In failed: \(error.localizedDescription)")
      signInContinuation?.resume(throwing: AuthError.invalidCredential(error.localizedDescription))
    }

    signInContinuation = nil
    currentNonce = nil
  }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleOAuthRepositoryImpl: ASAuthorizationControllerPresentationContextProviding {
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
#if canImport(UIKit)
    return UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .first ?? ASPresentationAnchor()
#else
    return ASPresentationAnchor()
#endif
  }
}
