//
//  AuthSessionManager.swift
//  Repository
//
//  Created by Wonji Suh on 1/2/26.
//

import Foundation
import Alamofire
import DomainInterface
import Entity
import WeaveDI

final class AuthSessionManager {
    static let shared = AuthSessionManager()

    @Dependency(\.keychainManager) var keychainManager
    
    // 인터셉터가 직접 크리덴셜을 관리하지 않으므로, SessionManager가 크리덴셜을 소유하고 관리합니다.
    var credential: AccessTokenCredential?
    
    let session: Session

    private init() {
        // AuthInterceptor를 세션의 인터셉터로 직접 사용합니다.
        self.session = Session(interceptor: AuthInterceptor())
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
        // Keychain에서도 삭제가 필요하다면 여기에 로직 추가
        // keychainManager.deleteTokens()
    }
}

private extension AuthSessionManager {
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