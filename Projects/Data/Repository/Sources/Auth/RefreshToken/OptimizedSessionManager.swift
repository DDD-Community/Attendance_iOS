//
//  OptimizedSessionManager.swift
//  Repository
//
//  Created by Network Optimizer on 1/10/26.
//

import Foundation
import Alamofire
import DomainInterface
import Entity
import WeaveDI

/// 네트워킹 성능 최적화된 세션 매니저
final class OptimizedSessionManager {
    static let shared = OptimizedSessionManager()

    @Dependency(\.keychainManager) var keychainManager

    // 인터셉터가 직접 크리덴셜을 관리하지 않으므로, SessionManager가 크리덴셜을 소유하고 관리합니다.
    var credential: AccessTokenCredential?

    let session: Session

    private init() {
        // 성능 최적화된 URLSessionConfiguration
        let configuration = URLSessionConfiguration.default

        // 1. 연결 풀링 최적화
        configuration.httpMaximumConnectionsPerHost = 6  // 기본값 6 유지
        configuration.requestCachePolicy = .useProtocolCachePolicy

        // 2. 타임아웃 최적화 (현실적인 값으로 조정)
        configuration.timeoutIntervalForRequest = 30.0     // 개별 요청 타임아웃 30초
        configuration.timeoutIntervalForResource = 120.0   // 전체 리소스 타임아웃 2분

        // 3. 캐시 설정 (50MB 메모리, 200MB 디스크)
        configuration.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,    // 50MB 메모리 캐시
            diskCapacity: 200 * 1024 * 1024,     // 200MB 디스크 캐시
            diskPath: "attendance_network_cache"
        )

        // 4. HTTP/2 및 멀티패스 연결 활성화
        configuration.multipathServiceType = .handover
        configuration.allowsCellularAccess = true
        configuration.allowsExpensiveNetworkAccess = true
        configuration.allowsConstrainedNetworkAccess = false  // 절약 모드에서 제한

        // 5. Keep-Alive 및 연결 재사용 최적화
        configuration.httpAdditionalHeaders = [
            "Connection": "keep-alive",
            "Keep-Alive": "timeout=120, max=1000"  // 2분 동안 최대 1000개 요청 재사용
        ]

        // 6. iOS 버전별 최적화 (필요시 추가 가능)

        // AuthInterceptor를 세션의 인터셉터로 직접 사용합니다.
        self.session = Session(
            configuration: configuration,
            interceptor: AuthInterceptor()
        )

        setupInitialCredential()
    }

    func updateCredential(with tokens: AuthTokens) {
        let newCredential = AccessTokenCredential.make(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken
        )
        self.credential = newCredential
    }

    func clear() {
        self.credential = nil
        // 캐시도 정리
        session.session.configuration.urlCache?.removeAllCachedResponses()
    }
}

private extension OptimizedSessionManager {
    func setupInitialCredential() {
        if let loadedCredential = loadCredentialFromKeychain() {
            self.credential = loadedCredential
        }
    }

    func loadCredentialFromKeychain() -> AccessTokenCredential? {
        let accessToken = keychainManager.accessToken()
        let refreshToken = keychainManager.refreshToken()

        guard
            let accessToken = accessToken,
            let refreshToken = refreshToken,
            !accessToken.isEmpty,
            !refreshToken.isEmpty
        else {
            return nil
        }

        return AccessTokenCredential.make(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}