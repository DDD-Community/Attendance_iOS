//
//  MockAuthRepository.swift
//  UseCaseTests
//
//  Created by TDD AI Automation on 2026-01-31
//

import Foundation
import DomainInterface
import Entity

@MainActor
public final class MockAuthRepository: AuthInterface {

    // MARK: - Call Tracking
    private(set) var loginCallCount = 0
    private(set) var refreshCallCount = 0
    private(set) var logoutCallCount = 0
    private(set) var withDrawCallCount = 0
    private(set) var updateSessionCredentialCallCount = 0

    private(set) var lastLoginProvider: SocialType?
    private(set) var lastLoginToken: String?
    private(set) var lastWithdrawToken: String?
    private(set) var lastUpdateTokens: AuthTokens?

    // MARK: - Response Configuration
    public var loginResponse: Result<LoginEntity, Error> = .failure(AuthError.invalidToken)
    public var refreshResponse: Result<AuthTokens, Error> = .failure(AuthError.tokenExpired)
    public var logoutResponse: Result<AuthExitEntity, Error> = .success(AuthExitEntity())
    public var withdrawResponse: Result<WithdrawEntity, Error> = .success(WithdrawEntity(isSuccess: true))

    // MARK: - Async Delays for Testing
    public var loginDelay: TimeInterval = 0
    public var refreshDelay: TimeInterval = 0
    public var logoutDelay: TimeInterval = 0
    public var withdrawDelay: TimeInterval = 0

    public init() {}

    // MARK: - AuthInterface Implementation
    public func login(provider: SocialType, token: String) async throws -> LoginEntity {
        if loginDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(loginDelay * 1_000_000_000))
        }

        loginCallCount += 1
        lastLoginProvider = provider
        lastLoginToken = token

        switch loginResponse {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        }
    }

    public func refresh() async throws -> AuthTokens {
        if refreshDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(refreshDelay * 1_000_000_000))
        }

        refreshCallCount += 1

        switch refreshResponse {
        case .success(let tokens):
            return tokens
        case .failure(let error):
            throw error
        }
    }

    public func logout() async throws -> AuthExitEntity {
        if logoutDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(logoutDelay * 1_000_000_000))
        }

        logoutCallCount += 1

        switch logoutResponse {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        }
    }

    public func withDraw(token: String) async throws -> WithdrawEntity {
        if withdrawDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(withdrawDelay * 1_000_000_000))
        }

        withDrawCallCount += 1
        lastWithdrawToken = token

        switch withdrawResponse {
        case .success(let entity):
            return entity
        case .failure(let error):
            throw error
        }
    }

    public func updateSessionCredential(with tokens: AuthTokens) {
        updateSessionCredentialCallCount += 1
        lastUpdateTokens = tokens
    }

    // MARK: - Test Helpers
    public func reset() {
        loginCallCount = 0
        refreshCallCount = 0
        logoutCallCount = 0
        withDrawCallCount = 0
        updateSessionCredentialCallCount = 0

        lastLoginProvider = nil
        lastLoginToken = nil
        lastWithdrawToken = nil
        lastUpdateTokens = nil

        loginResponse = .failure(AuthError.invalidToken)
        refreshResponse = .failure(AuthError.tokenExpired)
        logoutResponse = .success(AuthExitEntity())
        withdrawResponse = .success(WithdrawEntity(isSuccess: true))

        loginDelay = 0
        refreshDelay = 0
        logoutDelay = 0
        withdrawDelay = 0
    }

    public func configureSuccessfulLogin(
        name: String = "Test User",
        isNewUser: Bool = false,
        provider: SocialType = .google,
        role: Staff? = .member
    ) {
        let tokens = AuthTokens(
            accessToken: "mock_access_token",
            refreshToken: "mock_refresh_token",
            oauthRefreshToken: provider == .apple ? nil : "mock_oauth_refresh_token"
        )

        let entity = LoginEntity(
            name: name,
            isNewUser: isNewUser,
            provider: provider,
            token: tokens,
            role: role
        )

        loginResponse = .success(entity)
    }

    public func configureSuccessfulRefresh() {
        let tokens = AuthTokens(
            accessToken: "refreshed_access_token",
            refreshToken: "refreshed_refresh_token"
        )
        refreshResponse = .success(tokens)
    }

    public func configureLoginFailure(_ error: Error) {
        loginResponse = .failure(error)
    }

    public func configureRefreshFailure(_ error: Error) {
        refreshResponse = .failure(error)
    }

    public func configureLogoutFailure(_ error: Error) {
        logoutResponse = .failure(error)
    }

    public func configureWithdrawFailure(_ error: Error) {
        withdrawResponse = .failure(error)
    }
}

// MARK: - Auth Test Errors
public enum AuthError: Error, Equatable {
    case invalidToken
    case tokenExpired
    case networkError
    case unauthorized
    case serverError
    case invalidCredentials
    case userNotFound

    public var localizedDescription: String {
        switch self {
        case .invalidToken:
            return "Invalid authentication token"
        case .tokenExpired:
            return "Authentication token expired"
        case .networkError:
            return "Network connection error"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError:
            return "Server error occurred"
        case .invalidCredentials:
            return "Invalid credentials provided"
        case .userNotFound:
            return "User not found"
        }
    }
}