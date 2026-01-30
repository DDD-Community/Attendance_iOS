//
//  AuthEntityTest.swift
//  EntityTests
//
//  Created by TDD AI Automation on 2026-01-30
//

import Testing
@testable import Entity

@Suite("Auth Entity Tests - AI Generated")
struct AuthEntityTest {

    // MARK: - 토큰 보안성 테스트
    @Test("AuthTokens 보안 토큰 형식 검증")
    func test_auth_tokens_security_format() throws {
        // Given: AI가 분석한 토큰 보안 요구사항
        let tokens = AuthTokens.mockData()

        // Then: 토큰 보안 형식 검증
        #expect(tokens.accessToken.count > 20, "AccessToken 최소 길이 보안")
        #expect(tokens.refreshToken.count > 20, "RefreshToken 최소 길이 보안")
        #expect(tokens.accessToken.contains("mock_access_token"), "AccessToken 형식")
        #expect(tokens.refreshToken.contains("mock_refresh_token"), "RefreshToken 형식")
    }

    @Test("플랫폼별 OAuth 토큰 차이점 검증")
    func test_platform_specific_oauth_tokens() throws {
        // Given: 플랫폼별 토큰 정책 차이
        let googleTokens = AuthTokens.mockGoogleTokens()
        let appleTokens = AuthTokens.mockAppleTokens()

        // Then: 플랫폼별 토큰 정책 준수 검증
        #expect(googleTokens.oauthRefreshToken != nil, "Google은 OAuth Refresh Token 필요")
        #expect(appleTokens.oauthRefreshToken == nil, "Apple은 OAuth Refresh Token 불필요")
        #expect(googleTokens.accessToken.contains("google"), "Google 토큰 식별자")
        #expect(appleTokens.accessToken.contains("apple"), "Apple 토큰 식별자")
    }

    @Test("LoginEntity 사용자 상태 검증")
    func test_login_entity_user_state() throws {
        // Given: 다양한 사용자 로그인 상태
        let newUser = LoginEntity.mockNewUser()
        let existingMember = LoginEntity.mockGoogleUser()
        let existingManager = LoginEntity.mockManagerUser()

        // Then: 사용자 상태별 비즈니스 로직 검증
        #expect(newUser.isNewUser == true && newUser.role == nil, "신규 사용자는 역할 없음")
        #expect(existingMember.isNewUser == false && existingMember.role == .member, "기존 멤버")
        #expect(existingManager.isNewUser == false && existingManager.role == .manager, "매니저 권한")
    }

    @Test("Apple OAuth Payload 필수/선택 필드 검증")
    func test_apple_oauth_payload_fields() throws {
        // Given: Apple OAuth 정책에 따른 필드 검증
        let completePayload = AppleOAuthPayload.mockData()
        let noNamePayload = AppleOAuthPayload.mockDataWithoutName()
        let noAuthCodePayload = AppleOAuthPayload.mockDataWithoutAuthCode()

        // Then: Apple OAuth 필드 정책 검증
        #expect(completePayload.idToken.isEmpty == false, "ID Token 필수")
        #expect(completePayload.nonce.isEmpty == false, "Nonce 필수")
        #expect(noNamePayload.displayName == nil, "DisplayName 선택사항")
        #expect(noAuthCodePayload.authorizationCode == nil, "AuthCode 선택사항")
    }

    @Test("Google OAuth Payload 토큰 조합 검증")
    func test_google_oauth_payload_token_combinations() throws {
        // Given: Google OAuth 다양한 토큰 조합
        let fullTokens = GoogleOAuthPayload.mockData()
        let noAccessToken = GoogleOAuthPayload.mockDataWithoutAccessToken()
        let noAuthCode = GoogleOAuthPayload.mockDataWithoutAuthCode()

        // Then: Google OAuth 토큰 조합 정책 검증
        #expect(fullTokens.idToken.isEmpty == false, "ID Token 항상 필수")
        #expect(fullTokens.accessToken?.isEmpty == false, "Access Token 일반적으로 제공")
        #expect(noAccessToken.accessToken == nil, "Access Token 선택적 제공")
        #expect(noAuthCode.authorizationCode == nil, "Auth Code 선택적 제공")
    }

    @Test("회원탈퇴 플로우 보안 검증")
    func test_withdrawal_security_flow() throws {
        // Given: 회원탈퇴 보안 시나리오
        let successWithdraw = WithdrawEntity.mockSuccessData()
        let failureWithdraw = WithdrawEntity.mockFailureData()
        let unauthorizedWithdraw = WithdrawEntity.mockUnauthorizedData()

        // Then: 탈퇴 보안 정책 검증
        #expect(successWithdraw.isSuccess == true && successWithdraw.code == "200")
        #expect(failureWithdraw.isSuccess == false, "탈퇴 실패 명확한 표시")
        #expect(unauthorizedWithdraw.code == "401", "인증 실패 시 401 반환")
        #expect(unauthorizedWithdraw.message?.contains("인증") == true, "인증 메시지 명확성")
    }

    @Test("로그아웃 세션 관리 검증")
    func test_logout_session_management() throws {
        // Given: 로그아웃 세션 관리 시나리오
        let successLogout = AuthExitEntity.mockSuccessData()
        let failureLogout = AuthExitEntity.mockFailureData()
        let tokenExpiredLogout = AuthExitEntity.mockTokenExpiredData()

        // Then: 세션 관리 정책 검증
        #expect(successLogout.code == "200", "정상 로그아웃")
        #expect(successLogout.message?.contains("로그아웃") == true, "로그아웃 메시지")
        #expect(failureLogout.code == "500", "서버 오류")
        #expect(tokenExpiredLogout.code == "401", "토큰 만료")
    }

    @Test("OAuth 플로우 엔드투엔드 검증")
    func test_oauth_flow_end_to_end() throws {
        // Given: 완전한 OAuth 플로우 시뮬레이션
        let applePayload = AppleOAuthPayload.mockData()
        let googlePayload = GoogleOAuthPayload.mockData()

        // When: OAuth 로그인 성공 시나리오
        let appleLogin = LoginEntity.mockAppleUser()
        let googleLogin = LoginEntity.mockGoogleUser()

        // Then: OAuth 플로우 완성도 검증
        #expect(applePayload.idToken.contains("apple"), "Apple ID Token")
        #expect(googlePayload.idToken.contains("google"), "Google ID Token")
        #expect(appleLogin.provider == .apple, "Apple 로그인")
        #expect(googleLogin.provider == .google, "Google 로그인")
        #expect(appleLogin.token.accessToken.contains("apple"), "Apple 토큰 연결")
        #expect(googleLogin.token.accessToken.contains("google"), "Google 토큰 연결")
    }
}