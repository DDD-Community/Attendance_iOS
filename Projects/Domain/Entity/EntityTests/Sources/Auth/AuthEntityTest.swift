//
//  AuthEntityTest.swift
//  EntityTests
//
//  Created by TDD Automation on 2026-01-30
//

import Testing
import XCTest
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
}

class AuthEntityXCTest: XCTestCase {
    func test_WithdrawEntity_success_response() {
        // Given
        let withdraw = WithdrawEntity.mockSuccessData()

        // Then
        XCTAssertTrue(withdraw.isSuccess)
        XCTAssertEqual(withdraw.code, "200")
        XCTAssertNotNil(withdraw.message)
    }
}