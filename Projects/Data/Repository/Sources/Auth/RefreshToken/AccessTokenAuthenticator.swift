//
//  AccessTokenAuthenticator.swift
//  Repository
//
//  Created by Wonji Suh on 1/2/26.
//

import Foundation

import Alamofire
import Dependencies
import DomainInterface
import Entity

enum TokenRefreshError: Error {
    case missingRefreshToken
    case invalidAccessToken
}

actor TokenRefresher {
    @Dependency(\.authRepository) private var authRepository
    @Dependency(\.keychainManager) var keychainManager
    
    private var isRefreshing = false
    private var activeRequest: Task<AccessTokenCredential, Error>?

    func refreshCredential() async throws -> AccessTokenCredential {
        if let activeRequest = activeRequest {
            return try await activeRequest.value
        }

        let task = Task { () throws -> AccessTokenCredential in
            defer {
                isRefreshing = false
                activeRequest = nil
            }
            
            guard let refreshToken = keychainManager.refreshToken(), !refreshToken.isEmpty else {
                throw TokenRefreshError.missingRefreshToken
            }
            
            let tokens = try await authRepository.refresh()
            keychainManager.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)

            // ✅ AuthenticationInterceptor가 자동으로 credential 업데이트하므로 중복 호출 제거
            return AccessTokenCredential.make(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken
            )
        }
        
        activeRequest = task
        isRefreshing = true
        
        return try await task.value
    }
}

final class AccessTokenAuthenticator: Authenticator, @unchecked Sendable {
    typealias Credential = AccessTokenCredential
    
    private let refresher = TokenRefresher()

    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
    }
    
    func refresh(
        _ credential: Credential,
        for session: Session,
        completion: @escaping @Sendable (Result<Credential, Error>) -> Void
    ) {
        Task {
            do {
                let refreshedCredential = try await refresher.refreshCredential()
                completion(.success(refreshedCredential))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool {
        return response.statusCode == 401
    }
    
    func isRequest(
        _ urlRequest: URLRequest,
        authenticatedWith credential: Credential
    ) -> Bool {
        guard let token = urlRequest.headers["Authorization"] else { return false }
        return token == "Bearer \(credential.accessToken)"
    }
}