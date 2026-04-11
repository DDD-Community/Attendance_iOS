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
import Moya
import Combine
import LogMacro
import ComposableArchitecture

// MARK: - 알림 상수 정의 (타입 안전성 및 재사용성)
extension NSNotification.Name {
    /// 리프레시 토큰 만료 시 발송되는 알림
    /// 관찰자는 사용 후 반드시 removeObserver를 호출하여 메모리 누수를 방지해야 함
    static let refreshTokenExpired = NSNotification.Name("RefreshTokenExpired")
}

// MARK: - Token Refresh Manager
actor TokenRefreshManager {
    @Dependency(\.authRepository) private var authRepository
    @Dependency(\.keychainManager) private var keychainManager
  @Shared(.appStorage("staffRole")) var staffRole: Staff?

    private var isRefreshing = false

    func refreshCredentialIfNeeded() async throws -> AccessTokenCredential {
        // 이미 갱신 중인 요청이 있다면 양보 후 재시도
        if isRefreshing {
            // 다른 작업에 양보하고 재시도
           await _Concurrency.Task.yield()
            return try await refreshCredentialIfNeeded()
        }

        isRefreshing = true
        defer { isRefreshing = false }

      #logDebug("🔄 Starting token refresh...")

        do {
            let tokens = try await authRepository.refresh()
          #logDebug("✅ Token refresh completed successfully: \(tokens)")

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

            return newCredential
        } catch {
          #logDebug("❌ Token refresh failed: \(error)")

            // Refresh token이 만료된 경우 자동 로그아웃 수행
            if isRefreshTokenExpiredError(error) {
              #logDebug("🚪 [TokenRefreshManager] 401 ERROR DETECTED! Starting automatic logout...")
                await performAutomaticLogout()
              #logDebug("✅ [TokenRefreshManager] Automatic logout completed, throwing refresh token expired error")
                throw AuthError.refreshTokenExpired
            } else {
              #logDebug("⚠️ [TokenRefreshManager] Non-401 error, rethrowing: \(error)")
                throw error
            }
        }
    }

    /// Refresh token이 만료된 에러인지 확인
    private func isRefreshTokenExpiredError(_ error: Error) -> Bool {
        #logDebug("🔍 [TokenRefreshManager] 🚨 CHECKING IF 401 ERROR: \(error)")

        // 1. statusCodeError(401) 직접 감지 (최우선)
        let errorString = String(describing: error)
        if errorString.contains("statusCodeError(401)") {
            #logDebug("🎯 [TokenRefreshManager] ✅ statusCodeError(401) DETECTED!")
            return true
        }

        // 2. Moya의 MoyaError를 통해 HTTP 상태 코드 확인
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                #logDebug("📋 [TokenRefreshManager] MoyaError statusCode: \(response.statusCode)")
                if response.statusCode == 401 {
                    #logDebug("🎯 [TokenRefreshManager] ✅ MoyaError 401 DETECTED!")
                    return true
                }
            case .underlying(_, let response):
                #logDebug("📋 [TokenRefreshManager] MoyaError underlying statusCode: \(String(describing: response?.statusCode))")
                if response?.statusCode == 401 {
                    #logDebug("🎯 [TokenRefreshManager] ✅ MoyaError underlying 401 DETECTED!")
                    return true
                }
            default:
                #logDebug("📋 [TokenRefreshManager] Other MoyaError: \(moyaError)")
            }
        }

        // 3. AuthError인 경우
        if let authError = error as? AuthError {
            #logDebug("📋 [TokenRefreshManager] AuthError: \(authError)")
            if authError.isTokenExpiredError {
                #logDebug("🎯 [TokenRefreshManager] ✅ AuthError TOKEN EXPIRED DETECTED!")
                return true
            }
        }

        // 4. 에러 메시지에서 401 키워드 확인 (더 포괄적으로)
        let errorDesc = error.localizedDescription.lowercased()
        if errorDesc.contains("401") ||
           errorDesc.contains("unauthorized") ||
           errorDesc.contains("유효하지 않은 토큰") ||
           errorDesc.contains("invalid token") ||
           errorDesc.contains("token expired") ||
           errorDesc.contains("authentication failed") {
            #logDebug("🎯 [TokenRefreshManager] ✅ ERROR MESSAGE 401 DETECTED: \(errorDesc)")
            return true
        }

        #logDebug("❌ [TokenRefreshManager] Error is NOT 401 - continuing normally")
        return false
    }

    /// 자동 로그아웃 수행 (로컬 상태 정리만)
    private func performAutomaticLogout() async {
      #logDebug("🚪 [TokenRefreshManager] 🔥 PERFORMING AUTOMATIC LOGOUT - 401 ERROR DETECTED!")

        // Refresh token이 만료된 상황이므로 서버 API 호출은 불가능
        // 로컬 상태만 정리함

        // 1. Keychain에서 모든 토큰 제거
        #logDebug("🔑 [TokenRefreshManager] Clearing keychain tokens...")
        keychainManager.clear()
        self.$staffRole.withLock { $0 = nil }
        #logDebug("✅ [TokenRefreshManager] Keychain cleared")

        // 2. AuthSessionManager credential 정리
        #logDebug("🗂️ [TokenRefreshManager] Clearing session manager...")
        await MainActor.run {
            AuthSessionManager.shared.credential = nil
        }
        #logDebug("✅ [TokenRefreshManager] Session manager cleared")

        // 3. 전역 로그인 만료 알림 전송 - 확실하게 발송
        // ⚠️ 중요: 이 알림을 관찰하는 코드는 반드시 deinit에서 removeObserver를 호출해야 함
        #logDebug("📢 [TokenRefreshManager] 🚨 SENDING LOGOUT NOTIFICATION...")
        await MainActor.run {
            NotificationCenter.default.post(
                name: .refreshTokenExpired,
                object: nil,
                userInfo: ["reason": "401_refresh_failed"] // 추가 정보
            )
            #logDebug("✅ [TokenRefreshManager] 🎯 RefreshTokenExpired NOTIFICATION SENT!")
        }

        #logDebug("✅ [TokenRefreshManager] 🔥 AUTOMATIC LOGOUT COMPLETED!")
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
          _Concurrency.Task {
                do {
                    // 토큰 갱신 (동시성 안전하게 처리됨)
                    let newCredential = try await tokenRefreshManager.refreshCredentialIfNeeded()
                    adaptedRequest.headers.update(.authorization(bearerToken: newCredential.accessToken))
                    completion(.success(adaptedRequest))
                } catch {
                  #logDebug("❌ Token refresh failed in adapt: \(error)")
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

      #logDebug("🚨 401 Unauthorized detected, attempting token refresh for retry")

      _Concurrency.Task {
            do {
                // 토큰 갱신 시도
                _ = try await tokenRefreshManager.refreshCredentialIfNeeded()
                // 갱신 성공 시 원래 요청 재시도
                completion(.retry)
            } catch {
              #logDebug("❌ Token refresh failed in retry: \(error)")

                // Refresh token이 만료된 경우 특별 처리
                if let authError = error as? AuthError, authError.isTokenExpiredError {
                  #logDebug("🚪 Refresh token expired in retry - user will be automatically logged out")
                    // 자동 로그아웃이 이미 TokenRefreshManager에서 수행되었으므로
                    // 단순히 에러를 전달하여 UI가 적절히 대응할 수 있도록 함
                    completion(.doNotRetryWithError(authError))
                } else {
                    // 갱신 실패 시 재시도하지 않고 에러 전달
                    completion(.doNotRetryWithError(error))
                }
            }
        }
    }
}
