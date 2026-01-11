//
//  AuthInterceptor.swift
//  Repository
//
//  Created by Wonji Suh on 1/8/26.
//

import Foundation
import Alamofire
import DomainInterface
import Entity
import Dependencies

// MARK: - Token Refresh Manager
actor TokenRefreshManager {
    @Dependency(\.authRepository) private var authRepository
    @Dependency(\.keychainManager) private var keychainManager

    private var isRefreshing = false
    private var refreshTask: Task<AccessTokenCredential, Error>?

    func refreshCredentialIfNeeded() async throws -> AccessTokenCredential {
        // 이미 갱신 중인 요청이 있다면 그 결과를 기다림
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }

        // 새로운 갱신 작업 시작
        let task = Task<AccessTokenCredential, Error> {
            defer {
                isRefreshing = false
                refreshTask = nil
            }

            isRefreshing = true

            print("🔄 Starting token refresh...")
            let tokens = try await authRepository.refresh()
            print(tokens)
            // 키체인에 새 토큰 저장
            keychainManager.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)

            // AuthSessionManager에 새 credential 업데이트
            let newCredential = AccessTokenCredential.make(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken
            )

            // 메인 스레드에서 세션 매니저 업데이트
            await MainActor.run {
                AuthSessionManager.shared.credential = newCredential
            }

            print("✅ Token refresh completed successfully")
            return newCredential
        }

        refreshTask = task
        return try await task.value
    }
}

// MARK: - Auth Interceptor
final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    private let tokenRefreshManager = TokenRefreshManager()

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest

        // AuthSessionManager에서 현재 credential 가져오기
        guard let credential = AuthSessionManager.shared.credential else {
            // 토큰이 없으면 원본 요청 그대로 전달
            completion(.success(urlRequest))
            return
        }

        // 토큰이 곧 만료되는지 확인
        if credential.requiresRefresh {
            Task {
                do {
                    // 토큰 갱신 (동시성 안전하게 처리됨)
                    let newCredential = try await tokenRefreshManager.refreshCredentialIfNeeded()
                    adaptedRequest.headers.update(.authorization(bearerToken: newCredential.accessToken))
                    completion(.success(adaptedRequest))
                } catch {
                    print("❌ Token refresh failed in adapt: \(error)")
                    completion(.failure(error))
                }
            }
        } else {
            // 토큰이 아직 유효하면 그대로 사용
            adaptedRequest.headers.update(.authorization(bearerToken: credential.accessToken))
            completion(.success(adaptedRequest))
        }
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // 401 Unauthorized 에러가 아니면 재시도하지 않음
        guard let response = request.response, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }

        print("🚨 401 Unauthorized detected, attempting token refresh for retry")

        Task {
            do {
                // 토큰 갱신 시도
                _ = try await tokenRefreshManager.refreshCredentialIfNeeded()
                // 갱신 성공 시 원래 요청 재시도
                completion(.retry)
            } catch {
                print("❌ Token refresh failed in retry: \(error)")
                // 갱신 실패 시 재시도하지 않고 에러 전달
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
