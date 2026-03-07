//
//  AuthTestFixture.swift
//  UseCaseTests
//
//  Created by TDD AI Automation on 2026-01-31
//

import Foundation
import Entity

// MARK: - Auth Test Fixtures
public struct AuthTestFixture {

    // MARK: - Login Entities
    public static let successfulGoogleLogin = LoginEntity(
        name: "Google Test User",
        isNewUser: false,
        provider: .google,
        token: AuthTokens(
            accessToken: "google_access_token_12345",
            refreshToken: "google_refresh_token_67890",
            oauthRefreshToken: "google_oauth_refresh_token_abcde"
        ),
        role: .member
    )

    public static let successfulAppleLogin = LoginEntity(
        name: "Apple Test User",
        isNewUser: false,
        provider: .apple,
        token: AuthTokens(
            accessToken: "apple_access_token_54321",
            refreshToken: "apple_refresh_token_09876",
            oauthRefreshToken: nil // Apple doesn't provide OAuth refresh token
        ),
        role: .manager
    )

    public static let newUserGoogleLogin = LoginEntity(
        name: "New Google User",
        isNewUser: true,
        provider: .google,
        token: AuthTokens(
            accessToken: "new_google_access_token",
            refreshToken: "new_google_refresh_token",
            oauthRefreshToken: "new_google_oauth_refresh"
        ),
        role: nil
    )

    public static let newUserAppleLogin = LoginEntity(
        name: "New Apple User",
        isNewUser: true,
        provider: .apple,
        token: AuthTokens(
            accessToken: "new_apple_access_token",
            refreshToken: "new_apple_refresh_token",
            oauthRefreshToken: nil
        ),
        role: nil
    )

    // MARK: - Auth Tokens
    public static let validAuthTokens = AuthTokens(
        accessToken: "valid_access_token_12345",
        refreshToken: "valid_refresh_token_67890",
        oauthRefreshToken: "valid_oauth_refresh_token"
    )

    public static let expiredAuthTokens = AuthTokens(
        accessToken: "expired_access_token",
        refreshToken: "expired_refresh_token",
        oauthRefreshToken: "expired_oauth_refresh"
    )

    public static let refreshedAuthTokens = AuthTokens(
        accessToken: "refreshed_access_token_new",
        refreshToken: "refreshed_refresh_token_new",
        oauthRefreshToken: "refreshed_oauth_token_new"
    )

    public static let appleAuthTokens = AuthTokens(
        accessToken: "apple_access_token",
        refreshToken: "apple_refresh_token",
        oauthRefreshToken: nil
    )

    public static let googleAuthTokens = AuthTokens(
        accessToken: "google_access_token",
        refreshToken: "google_refresh_token",
        oauthRefreshToken: "google_oauth_refresh_token"
    )

    // MARK: - Auth Exit Entities
    public static let successfulLogout = AuthExitEntity(
        code: "200",
        message: "Successfully logged out",
        detail: "User session terminated"
    )

    public static let failedLogout = AuthExitEntity(
        code: "500",
        message: "Logout failed",
        detail: "Server error during logout"
    )

    // MARK: - Withdraw Entities
    public static let successfulWithdraw = WithdrawEntity(
        isSuccess: true,
        code: "200",
        message: "Account successfully deleted",
        detail: "All user data has been removed"
    )

    public static let failedWithdraw = WithdrawEntity(
        isSuccess: false,
        code: "403",
        message: "Withdrawal failed",
        detail: "Insufficient permissions"
    )

    // MARK: - Test Tokens
    public struct TestTokens {
        public static let validGoogleToken = "google_token_valid_12345"
        public static let validAppleToken = "apple_token_valid_67890"
        public static let invalidToken = "invalid_token"
        public static let expiredToken = "expired_token"
        public static let emptyToken = ""
        public static let malformedToken = "malformed..token"
        public static let tooLongToken = String(repeating: "a", count: 1000)
        public static let tooShortToken = "a"
        public static let withdrawToken = "withdraw_token_12345"
    }

    // MARK: - Test User Names
    public struct TestUserNames {
        public static let validName = "Test User"
        public static let longName = String(repeating: "김", count: 50)
        public static let emptyName = ""
        public static let specialCharacterName = "User@#$%"
        public static let numberName = "User123"
        public static let unicodeName = "사용자👤"
    }

    // MARK: - Common Test Scenarios
    public struct Scenarios {
        public static func makeLoginEntity(
            provider: SocialType,
            isNewUser: Bool = false,
            role: Staff? = .member,
            name: String = "Test User"
        ) -> LoginEntity {
            return LoginEntity(
                name: name,
                isNewUser: isNewUser,
                provider: provider,
                token: provider == .apple ? appleAuthTokens : googleAuthTokens,
                role: isNewUser ? nil : role
            )
        }

        public static func makeUserSession(
            for loginEntity: LoginEntity
        ) -> UserSession {
            return UserSession(
                userID: loginEntity.isNewUser ? 0 : 123,
                name: loginEntity.name,
                selectPart: loginEntity.isNewUser ? .all : .development,
                userRole: loginEntity.role ?? .member,
                managing: loginEntity.role == .manager ? [.development] : [],
                provider: loginEntity.provider,
                selectTeam: loginEntity.isNewUser ? .unknown : .teamA,
                selectTeamId: loginEntity.isNewUser ? nil : 1,
                token: "user_session_token",
                generationId: loginEntity.isNewUser ? 0 : 1,
                accessToken: loginEntity.token.accessToken,
                oauthRefreshToken: loginEntity.token.oauthRefreshToken,
                inviteCode: loginEntity.isNewUser ? "" : "ABC123",
                generation: loginEntity.isNewUser ? "" : "1기"
            )
        }
    }

    // MARK: - Error Test Cases
    public struct ErrorCases {
        public static let networkError = NSError(
            domain: "NetworkErrorDomain",
            code: -1009,
            userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."]
        )

        public static let serverError = NSError(
            domain: "ServerErrorDomain",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: "Internal server error"]
        )

        public static let timeoutError = NSError(
            domain: "TimeoutErrorDomain",
            code: -1001,
            userInfo: [NSLocalizedDescriptionKey: "The request timed out."]
        )

        public static let unauthorizedError = NSError(
            domain: "AuthErrorDomain",
            code: 401,
            userInfo: [NSLocalizedDescriptionKey: "Unauthorized access"]
        )
    }

    // MARK: - Concurrent Test Data
    public struct ConcurrentTestData {
        public static let simultaneousLoginCount = 5
        public static let concurrentProviders: [SocialType] = [.google, .apple, .google, .apple, .google]
        public static let concurrentTokens = [
            "concurrent_token_1",
            "concurrent_token_2",
            "concurrent_token_3",
            "concurrent_token_4",
            "concurrent_token_5"
        ]
    }
}