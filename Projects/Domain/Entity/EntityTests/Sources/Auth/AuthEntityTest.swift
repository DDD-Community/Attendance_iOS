//
//  AuthEntityTest.swift
//  EntityTests
//
//  Created by TDD Automation on 2026-01-30
//

import Testing
@testable import Entity

@Suite("Auth Entity Tests")
struct AuthEntityTest {

    @Test("AuthTokens Mock 데이터 생성 테스트")
    func test_AuthTokens_mock_data_creation() throws {
        // Given
        let tokens = AuthTokens.mockData()

        // Then
        #expect(tokens.accessToken.contains("mock_access_token"))
        #expect(tokens.refreshToken.contains("mock_refresh_token"))
        #expect(tokens.oauthRefreshToken != nil)
    }

    @Test("LoginEntity Google 사용자 테스트")
    func test_LoginEntity_google_user() throws {
        // Given
        let loginEntity = LoginEntity.mockGoogleUser()

        // Then
        #expect(loginEntity.name == "김철수")
        #expect(loginEntity.provider == .google)
        #expect(loginEntity.isNewUser == false)
        #expect(loginEntity.role == .member)
    }

    @Test("AppleOAuthPayload Mock 데이터 테스트")
    func test_AppleOAuthPayload_mock_data() throws {
        // Given
        let payload = AppleOAuthPayload.mockData()

        // Then
        #expect(payload.idToken.contains("mock_apple_id_token"))
        #expect(payload.displayName == "Kim Chulsu")
        #expect(payload.authorizationCode != nil)
    }

    @Test("WithdrawEntity 성공 응답 테스트")
    func test_WithdrawEntity_success_response() throws {
        // Given
        let withdraw = WithdrawEntity.mockSuccessData()

        // Then
        #expect(withdraw.isSuccess == true)
        #expect(withdraw.code == "200")
        #expect(withdraw.message != nil)
    }

    @Test("AuthExitEntity 로그아웃 테스트")
    func test_AuthExitEntity_logout() throws {
        // Given
        let authExit = AuthExitEntity.mockSuccessData()

        // Then
        #expect(authExit.code == "200")
        #expect(authExit.message?.contains("로그아웃") == true)
    }

    @Test("Google OAuth Payload 토큰 테스트")
    func test_GoogleOAuthPayload_tokens() throws {
        // Given
        let payload = GoogleOAuthPayload.mockData()

        // Then
        #expect(payload.idToken.contains("mock_google_id_token"))
        #expect(payload.accessToken?.contains("mock_google_access_token") == true)
        #expect(payload.displayName == "Kim Chulsu")
    }

    @Test("AuthTokens 플랫폼별 테스트")
    func test_AuthTokens_platform_specific() throws {
        // Given
        let googleTokens = AuthTokens.mockGoogleTokens()
        let appleTokens = AuthTokens.mockAppleTokens()

        // Then
        #expect(googleTokens.accessToken.contains("google"))
        #expect(appleTokens.accessToken.contains("apple"))
        #expect(googleTokens.oauthRefreshToken != nil)
        #expect(appleTokens.oauthRefreshToken == nil)
    }

    @Test("LoginEntity 신규/기존 사용자 구분 테스트")
    func test_LoginEntity_new_vs_existing_user() throws {
        // Given
        let newUser = LoginEntity.mockNewUser()
        let existingUser = LoginEntity.mockGoogleUser()

        // Then
        #expect(newUser.isNewUser == true)
        #expect(existingUser.isNewUser == false)
        #expect(newUser.role == nil)
        #expect(existingUser.role != nil)
    }

    @Test("OAuth Payload 옵셔널 필드 테스트")
    func test_OAuth_payload_optional_fields() throws {
        // Given
        let appleWithoutName = AppleOAuthPayload.mockDataWithoutName()
        let googleWithoutAccess = GoogleOAuthPayload.mockDataWithoutAccessToken()

        // Then
        #expect(appleWithoutName.displayName == nil)
        #expect(appleWithoutName.authorizationCode != nil)
        #expect(googleWithoutAccess.accessToken == nil)
        #expect(googleWithoutAccess.idToken.contains("mock_google"))
    }

    @Test("WithdrawEntity 다양한 응답 시나리오 테스트")
    func test_WithdrawEntity_response_scenarios() throws {
        // Given
        let success = WithdrawEntity.mockSuccessData()
        let failure = WithdrawEntity.mockFailureData()
        let unauthorized = WithdrawEntity.mockUnauthorizedData()

        // Then
        #expect(success.isSuccess == true)
        #expect(failure.isSuccess == false)
        #expect(unauthorized.code == "401")
        #expect(failure.code == "400")
        #expect(unauthorized.message?.contains("인증") == true)
    }
}
