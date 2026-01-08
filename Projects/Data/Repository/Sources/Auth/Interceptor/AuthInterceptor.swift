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

final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {
    @Dependency(\.authRepository) private var authRepository
    @Dependency(\.keychainManager) private var keychainManager

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        
        // AuthSessionManager에서 현재 크리덴셜 가져오기
        guard let credential = AuthSessionManager.shared.credential else {
            completion(.success(urlRequest))
            return
        }
        
        // adapt 단계에서 토큰 만료 여부 확인
        if credential.requiresRefresh {
            Task {
                do {
                    let tokens = try await authRepository.refresh()
                    keychainManager.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
                    authRepository.updateSessionCredential(with: tokens)
                    adaptedRequest.headers.update(.authorization(bearerToken: tokens.accessToken))
                    completion(.success(adaptedRequest))
                } catch {
                    completion(.failure(error))
                }
            }
        } else {
            adaptedRequest.headers.update(.authorization(bearerToken: credential.accessToken))
            completion(.success(adaptedRequest))
        }
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // HTTP 401 에러가 아니면 재시도하지 않음
        guard let response = request.response, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        Task {
            do {
                // 토큰 갱신 시도
                let tokens = try await authRepository.refresh()
                keychainManager.save(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
                authRepository.updateSessionCredential(with: tokens)
                // 갱신 성공 시, 원래 요청 재시도
                completion(.retry)
            } catch {
                // 갱신 실패 시, 재시도하지 않고 에러 전달
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
