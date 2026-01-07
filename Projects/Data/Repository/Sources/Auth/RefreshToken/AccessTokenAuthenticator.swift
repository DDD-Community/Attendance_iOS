//
//  AccessTokenAuthenticator.swift
//  Repository
//
//  Created by Wonji Suh  on 1/2/26.
//

import Foundation

import Alamofire
import Dependencies
import DomainInterface
import Entity
import UseCase

enum TokenRefreshError: Error {
  case missingRefreshToken
  case invalidAccessToken
}

final class AccessTokenAuthenticator: Authenticator, @unchecked Sendable {
  typealias Credential = AccessTokenCredential

  @Dependency(\.authRepository) private var authRepository
  private let keychainManager = KeychainManager()

  func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
    urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
  }

  func refresh(
    _ credential: Credential,
    for session: Session,
    completion: @escaping @Sendable (Result<Credential, Error>) -> Void
  ) {
    Task {
      completion(await refreshCredential(credential))
    }
  }

  func didRequest(
    _ urlRequest: URLRequest,
    with response: HTTPURLResponse,
    failDueToAuthenticationError error: Error
  ) -> Bool {
    response.statusCode == 401
  }

  func isRequest(
    _ urlRequest: URLRequest,
    authenticatedWith credential: Credential
  ) -> Bool {
    urlRequest.headers["Authorization"] == "Bearer \(credential.accessToken)"
  }
}

private extension AccessTokenAuthenticator {
  func refreshCredential(_ credential: Credential) async -> Result<Credential, Error> {
    guard let refreshToken = keychainManager.refreshToken(), !refreshToken.isEmpty else {
      return .failure(TokenRefreshError.missingRefreshToken)
    }

    do {
      let tokens = try await authRepository.refresh()
      keychainManager.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)

      // AuthSessionManager의 credential도 업데이트
      AuthSessionManager.shared.updateCredential(with: tokens)

      let refreshedCredential = AccessTokenCredential.make(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken
      )

      return .success(refreshedCredential)
    } catch {
      return .failure(error)
    }
  }
}
