//
//  AuthUseCaseTest.swift
//  UseCaseTests
//
//  Created by TDD AI Automation on 2026-01-31
//

import Testing
import Foundation
import ComposableArchitecture
@testable import UseCase
@testable import Entity
@testable import DomainInterface

@Suite("Auth UseCase Tests - Complete TDD Implementation", .tags(.unit, .auth))
@MainActor
struct AuthUseCaseTest {

    // MARK: - Test Dependencies
    private var mockAuthRepository: MockAuthRepository!
    private var mockKeychainManager: MockKeychainManager!
    private var mockUserSession: MockUserSession!

    init() async {
        mockAuthRepository = MockAuthRepository()
        mockKeychainManager = MockKeychainManager()
        mockUserSession = MockUserSession()
    }

    // MARK: - Tier 1: Core Login Flow (6 Test Cases)

    @Test("TC-001: Apple 로그인 성공 (신규 사용자)")
    func test_apple_login_success_new_user() async throws {
        // Given: Apple 신규 사용자 로그인 설정
        let expectedProvider = SocialType.apple
        let expectedToken = AuthTestFixture.TestTokens.validAppleToken
        let expectedName = "신규 Apple 사용자"

        mockAuthRepository.configureSuccessfulLogin(
            name: expectedName,
            isNewUser: true,
            provider: expectedProvider,
            role: nil
        )

        // When: Apple 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager,
            mockUserSession: mockUserSession
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: expectedProvider, token: expectedToken)
        }

        // Then: 신규 사용자 로그인 검증
        AuthTestHelper.verifyLoginSuccess(
            result: result,
            expectedProvider: expectedProvider,
            expectedName: expectedName,
            expectedIsNewUser: true,
            expectedRole: nil
        )

        AuthTestHelper.verifyTokenStorage(
            mockKeychain: mockKeychainManager,
            expectedAccessToken: result.token.accessToken,
            expectedRefreshToken: result.token.refreshToken
        )

        AuthTestHelper.validateAuthTokens(result.token, shouldHaveOAuthToken: false)
        AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLoginCalls: 1)
    }

    @Test("TC-002: Apple 로그인 성공 (기존 사용자)")
    func test_apple_login_success_existing_user() async throws {
        // Given: Apple 기존 사용자 로그인 설정
        let expectedProvider = SocialType.apple
        let expectedToken = AuthTestFixture.TestTokens.validAppleToken
        let expectedName = "기존 Apple 사용자"
        let expectedRole = Staff.manager

        mockAuthRepository.configureSuccessfulLogin(
            name: expectedName,
            isNewUser: false,
            provider: expectedProvider,
            role: expectedRole
        )

        // When: Apple 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager,
            mockUserSession: mockUserSession
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: expectedProvider, token: expectedToken)
        }

        // Then: 기존 사용자 로그인 검증
        AuthTestHelper.verifyLoginSuccess(
            result: result,
            expectedProvider: expectedProvider,
            expectedName: expectedName,
            expectedIsNewUser: false,
            expectedRole: expectedRole
        )

        AuthTestHelper.verifyTokenStorage(
            mockKeychain: mockKeychainManager,
            expectedAccessToken: result.token.accessToken,
            expectedRefreshToken: result.token.refreshToken
        )

        #expect(result.token.oauthRefreshToken == nil, "Apple 로그인은 oauthRefreshToken이 없어야 함")
        AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLoginCalls: 1)
    }

    @Test("TC-003: Google 로그인 성공 (신규 사용자)")
    func test_google_login_success_new_user() async throws {
        // Given: Google 신규 사용자 로그인 설정
        let expectedProvider = SocialType.google
        let expectedToken = AuthTestFixture.TestTokens.validGoogleToken
        let expectedName = "신규 Google 사용자"

        mockAuthRepository.configureSuccessfulLogin(
            name: expectedName,
            isNewUser: true,
            provider: expectedProvider,
            role: nil
        )

        // When: Google 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager,
            mockUserSession: mockUserSession
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: expectedProvider, token: expectedToken)
        }

        // Then: 신규 사용자 로그인 검증
        AuthTestHelper.verifyLoginSuccess(
            result: result,
            expectedProvider: expectedProvider,
            expectedName: expectedName,
            expectedIsNewUser: true,
            expectedRole: nil
        )

        AuthTestHelper.verifyTokenStorage(
            mockKeychain: mockKeychainManager,
            expectedAccessToken: result.token.accessToken,
            expectedRefreshToken: result.token.refreshToken
        )

        AuthTestHelper.validateAuthTokens(result.token, shouldHaveOAuthToken: true)
    }

    @Test("TC-004: Google 로그인 성공 (기존 사용자)")
    func test_google_login_success_existing_user() async throws {
        // Given: Google 기존 사용자 로그인 설정
        let expectedProvider = SocialType.google
        let expectedToken = AuthTestFixture.TestTokens.validGoogleToken
        let expectedName = "기존 Google 사용자"
        let expectedRole = Staff.member

        mockAuthRepository.configureSuccessfulLogin(
            name: expectedName,
            isNewUser: false,
            provider: expectedProvider,
            role: expectedRole
        )

        // When: Google 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager,
            mockUserSession: mockUserSession
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: expectedProvider, token: expectedToken)
        }

        // Then: 기존 사용자 로그인 검증
        AuthTestHelper.verifyLoginSuccess(
            result: result,
            expectedProvider: expectedProvider,
            expectedName: expectedName,
            expectedIsNewUser: false,
            expectedRole: expectedRole
        )

        #expect(result.token.oauthRefreshToken != nil, "Google 로그인은 oauthRefreshToken이 있어야 함")
        AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLoginCalls: 1)
    }

    @Test("TC-005: 로그인 실패 (잘못된 credential)")
    func test_login_failure_invalid_credentials() async throws {
        // Given: 잘못된 credential 에러 설정
        let invalidToken = AuthTestFixture.TestTokens.invalidToken
        mockAuthRepository.configureLoginFailure(AuthError.invalidCredentials)

        // When & Then: 로그인 실패 검증
        await #expect(throws: AuthError.self) {
            try await AuthTestHelper.withMockDependencies(
                mockAuthRepository: mockAuthRepository,
                mockKeychainManager: mockKeychainManager
            ) {
                let useCase = AuthUseCaseImpl()
                _ = try await useCase.login(provider: .google, token: invalidToken)
            }
        }

        // Then: 실패 시 부작용 없음 검증
        AuthTestHelper.verifyTokenStorage(
            mockKeychain: mockKeychainManager,
            expectedAccessToken: "",
            expectedRefreshToken: "",
            shouldBeCalled: false
        )
        AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLoginCalls: 1)
    }

    @Test("TC-006: 로그인 실패 (네트워크 오류)")
    func test_login_failure_network_error() async throws {
        // Given: 네트워크 에러 설정
        mockAuthRepository.configureLoginFailure(AuthError.networkError)

        // When & Then: 네트워크 에러 검증
        await #expect(throws: AuthError.self) {
            try await AuthTestHelper.withMockDependencies(
                mockAuthRepository: mockAuthRepository,
                mockKeychainManager: mockKeychainManager
            ) {
                let useCase = AuthUseCaseImpl()
                _ = try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
            }
        }

        // Then: 실패 시 상태 변경 없음 검증
        #expect(mockKeychainManager.saveCallCount == 0, "네트워크 오류 시 토큰이 저장되지 않아야 함")
    }

    // MARK: - Tier 2: Apple Specific Features (4 Test Cases)

    @Test("TC-007: Apple 사용자명 초기 저장")
    func test_apple_username_initial_save() async throws {
        // Given: Apple 사용자명 포함 로그인 설정
        let appleUserName = "Apple User 김철수"
        let loginEntity = AuthTestFixture.Scenarios.makeLoginEntity(
            provider: .apple,
            isNewUser: true,
            role: nil,
            name: appleUserName
        )
        mockAuthRepository.loginResponse = .success(loginEntity)

        // When: Apple 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
        }

        // Then: Apple 사용자명 저장 검증
        #expect(result.name == appleUserName, "Apple 사용자명이 정확히 저장되어야 함")
        #expect(result.provider == .apple, "Apple 제공자가 올바르게 설정되어야 함")
        #expect(result.token.oauthRefreshToken == nil, "Apple은 oauthRefreshToken이 없어야 함")
    }

    @Test("TC-008: Apple 사용자명 재사용")
    func test_apple_username_reuse() async throws {
        // Given: 기존 Apple 사용자 재로그인 시나리오
        let savedAppleUserName = "저장된 Apple 사용자"
        let loginEntity = AuthTestFixture.Scenarios.makeLoginEntity(
            provider: .apple,
            isNewUser: false,
            role: .member,
            name: savedAppleUserName
        )
        mockAuthRepository.loginResponse = .success(loginEntity)

        // When: Apple 재로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
        }

        // Then: 저장된 사용자명 재사용 검증
        #expect(result.name == savedAppleUserName, "저장된 Apple 사용자명이 재사용되어야 함")
        #expect(!result.isNewUser, "기존 사용자로 처리되어야 함")
        #expect(result.role == .member, "기존 사용자 권한이 유지되어야 함")
    }

    @Test("TC-009: Apple oauthRefreshToken 처리")
    func test_apple_oauth_refresh_token_handling() async throws {
        // Given: Apple 로그인 (oauthRefreshToken 없음)
        let loginEntity = AuthTestFixture.Scenarios.makeLoginEntity(provider: .apple, isNewUser: false)
        loginEntity.token
        mockAuthRepository.loginResponse = .success(loginEntity)

        // When: Apple 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
        }

        // Then: Apple oauthRefreshToken 처리 검증
        #expect(result.token.oauthRefreshToken == nil, "Apple은 oauthRefreshToken이 nil이어야 함")
        #expect(!result.token.accessToken.isEmpty, "accessToken은 존재해야 함")
        #expect(!result.token.refreshToken.isEmpty, "refreshToken은 존재해야 함")
    }

    @Test("TC-010: Apple nonce 검증 시뮬레이션")
    func test_apple_nonce_verification_simulation() async throws {
        // Given: Apple nonce 검증이 필요한 시나리오 (실제 nonce 검증은 Provider에서 처리)
        let loginEntity = AuthTestFixture.Scenarios.makeLoginEntity(provider: .apple, isNewUser: true)
        mockAuthRepository.loginResponse = .success(loginEntity)

        // When: Apple 로그인으로 nonce 포함 토큰 검증
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
        }

        // Then: Apple nonce 검증 통과 확인
        #expect(result.provider == .apple, "Apple 제공자로 처리되어야 함")
        #expect(mockAuthRepository.lastLoginProvider == .apple, "Repository에 Apple 제공자가 전달되어야 함")
        #expect(mockAuthRepository.lastLoginToken == AuthTestFixture.TestTokens.validAppleToken, "올바른 토큰이 전달되어야 함")
    }

    // MARK: - Tier 3: State Management (5 Test Cases)

    @Test("TC-011: UserSession 동기화")
    func test_user_session_synchronization() async throws {
        // Given: UserSession 동기화 필요한 로그인 설정
        let loginEntity = AuthTestFixture.successfulGoogleLogin
        mockAuthRepository.loginResponse = .success(loginEntity)

        // When: 로그인 실행 및 UserSession 업데이트
        _ = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager,
            mockUserSession: mockUserSession
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .google, token: AuthTestFixture.TestTokens.validGoogleToken)
        }

        // Then: UserSession 동기화 검증
        AuthTestHelper.verifyUserSessionUpdated(
            mockSession: mockUserSession,
            expectedOAuthToken: loginEntity.token.oauthRefreshToken
        )
    }

    @Test("TC-012: staffRole 업데이트")
    func test_staff_role_update() async throws {
        // Given: Manager 권한 사용자 로그인
        let managerLoginEntity = AuthTestFixture.Scenarios.makeLoginEntity(
            provider: .google,
            isNewUser: false,
            role: .manager
        )
        mockAuthRepository.loginResponse = .success(managerLoginEntity)

        // When: Manager 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .google, token: AuthTestFixture.TestTokens.validGoogleToken)
        }

        // Then: staffRole 업데이트 검증
        #expect(result.role == .manager, "Manager 권한이 설정되어야 함")
    }

    @Test("TC-013: 신규 사용자 path 검증")
    func test_new_user_path_verification() async throws {
        // Given: 신규 사용자 로그인 설정
        let newUserEntity = AuthTestFixture.newUserAppleLogin
        mockAuthRepository.loginResponse = .success(newUserEntity)

        // When: 신규 사용자 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
        }

        // Then: 신규 사용자 path 검증
        #expect(result.isNewUser, "신규 사용자로 표시되어야 함")
        #expect(result.role == nil, "신규 사용자는 role이 nil이어야 함")
        AuthTestHelper.verifyTokenStorage(
            mockKeychain: mockKeychainManager,
            expectedAccessToken: result.token.accessToken,
            expectedRefreshToken: result.token.refreshToken
        )
    }

    @Test("TC-014: 기존 사용자 path 검증")
    func test_existing_user_path_verification() async throws {
        // Given: 기존 사용자 로그인 설정
        let existingUserEntity = AuthTestFixture.successfulGoogleLogin
        mockAuthRepository.loginResponse = .success(existingUserEntity)

        // When: 기존 사용자 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .google, token: AuthTestFixture.TestTokens.validGoogleToken)
        }

        // Then: 기존 사용자 path 검증
        #expect(!result.isNewUser, "기존 사용자로 표시되어야 함")
        #expect(result.role != nil, "기존 사용자는 role이 있어야 함")
        #expect(result.role == .member, "올바른 role이 설정되어야 함")
    }

    @Test("TC-015: Keychain 토큰 저장 검증")
    func test_keychain_token_storage_verification() async throws {
        // Given: 토큰 저장 확인용 로그인 설정
        let loginEntity = AuthTestFixture.successfulAppleLogin
        mockAuthRepository.loginResponse = .success(loginEntity)

        // When: 로그인 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
        }

        // Then: Keychain 토큰 저장 검증
        AuthTestHelper.verifyTokenStorage(
            mockKeychain: mockKeychainManager,
            expectedAccessToken: result.token.accessToken,
            expectedRefreshToken: result.token.refreshToken
        )

        #expect(mockKeychainManager.hasStoredTokens, "토큰이 Keychain에 저장되어야 함")
        #expect(mockKeychainManager.accessToken() == result.token.accessToken, "저장된 accessToken이 일치해야 함")
        #expect(mockKeychainManager.refreshToken() == result.token.refreshToken, "저장된 refreshToken이 일치해야 함")
    }

    // MARK: - Tier 4: Error Handling & Edge Cases (5 Test Cases)

    @Test("TC-016: 빈 사용자명 처리")
    func test_empty_username_handling() async throws {
        // Given: 빈 사용자명으로 로그인 응답 설정
        let emptyNameEntity = AuthTestFixture.Scenarios.makeLoginEntity(
            provider: .google,
            isNewUser: true,
            name: ""
        )
        mockAuthRepository.loginResponse = .success(emptyNameEntity)

        // When: 빈 사용자명으로 로그인
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.login(provider: .google, token: AuthTestFixture.TestTokens.validGoogleToken)
        }

        // Then: 빈 사용자명 처리 검증
        #expect(result.name.isEmpty, "빈 사용자명이 그대로 반환되어야 함")
        AuthTestHelper.verifyTokenStorage(
            mockKeychain: mockKeychainManager,
            expectedAccessToken: result.token.accessToken,
            expectedRefreshToken: result.token.refreshToken
        )
    }

    @Test("TC-017: nil authorizationCode 처리")
    func test_nil_authorization_code_handling() async throws {
        // Given: 잘못된 토큰으로 인한 에러 설정
        mockAuthRepository.configureLoginFailure(AuthError.invalidToken)

        // When & Then: nil authorizationCode 에러 처리 검증
        await #expect(throws: AuthError.self) {
            try await AuthTestHelper.withMockDependencies(
                mockAuthRepository: mockAuthRepository,
                mockKeychainManager: mockKeychainManager
            ) {
                let useCase = AuthUseCaseImpl()
                _ = try await useCase.login(provider: .apple, token: "") // 빈 토큰
            }
        }

        // Then: 에러 시 상태 변경 없음 검증
        #expect(mockKeychainManager.saveCallCount == 0, "에러 시 토큰이 저장되지 않아야 함")
    }

    @Test("TC-018: nil googleToken 처리")
    func test_nil_google_token_handling() async throws {
        // Given: Google 토큰 에러 설정
        mockAuthRepository.configureLoginFailure(AuthError.invalidToken)

        // When & Then: nil Google 토큰 에러 검증
        await #expect(throws: AuthError.self) {
            try await AuthTestHelper.withMockDependencies(
                mockAuthRepository: mockAuthRepository,
                mockKeychainManager: mockKeychainManager
            ) {
                let useCase = AuthUseCaseImpl()
                _ = try await useCase.login(provider: .google, token: AuthTestFixture.TestTokens.invalidToken)
            }
        }

        AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLoginCalls: 1)
    }

    @Test("TC-019: SocialType 미지원 처리")
    func test_unsupported_social_type_handling() async throws {
        // Given: 지원되지 않는 SocialType (현재는 모두 지원하므로 에러 상황 시뮬레이션)
        mockAuthRepository.configureLoginFailure(AuthError.invalidCredentials)

        // When & Then: 지원되지 않는 제공자 에러 검증
        await #expect(throws: AuthError.self) {
            try await AuthTestHelper.withMockDependencies(
                mockAuthRepository: mockAuthRepository,
                mockKeychainManager: mockKeychainManager
            ) {
                let useCase = AuthUseCaseImpl()
                _ = try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.malformedToken)
            }
        }

        #expect(mockAuthRepository.lastLoginProvider == .apple, "Provider가 전달되어야 함")
    }

    @Test("TC-020: 동시 로그인 요청 처리")
    func test_concurrent_login_requests_handling() async throws {
        // Given: 동시 로그인 요청 설정
        let concurrentCount = AuthTestFixture.ConcurrentTestData.simultaneousLoginCount
        mockAuthRepository.configureSuccessfulLogin()
        mockAuthRepository.loginDelay = 0.1 // 약간의 지연 추가

        let concurrentOperations: [() async throws -> LoginEntity] = (0..<concurrentCount).map { index in
            {
                try await AuthTestHelper.withMockDependencies(
                    mockAuthRepository: self.mockAuthRepository,
                    mockKeychainManager: self.mockKeychainManager
                ) {
                    let useCase = AuthUseCaseImpl()
                    return try await useCase.login(
                        provider: AuthTestFixture.ConcurrentTestData.concurrentProviders[index],
                        token: AuthTestFixture.ConcurrentTestData.concurrentTokens[index]
                    )
                }
            }
        }

        // When: 동시 로그인 실행
        let results = try await AuthTestHelper.performConcurrentOperations(operations: concurrentOperations)

        // Then: 동시 로그인 결과 검증
        let successCount = results.compactMap { result in
            if case .success = result { return result }
            return nil
        }.count

        #expect(successCount == concurrentCount, "모든 동시 로그인이 성공해야 함")
        #expect(mockAuthRepository.loginCallCount == concurrentCount, "모든 로그인이 Repository를 호출해야 함")
    }

    // MARK: - Tier 5: Additional Core Methods (2 Test Cases)

    @Test("TC-021: Token refresh 성공")
    func test_token_refresh_success() async throws {
        // Given: 토큰 갱신 성공 설정
        let refreshedTokens = AuthTestFixture.refreshedAuthTokens
        mockAuthRepository.configureSuccessfulRefresh()
        mockAuthRepository.refreshResponse = .success(refreshedTokens)

        // When: 토큰 갱신 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.refresh()
        }

        // Then: 토큰 갱신 성공 검증
        #expect(result.accessToken == refreshedTokens.accessToken, "갱신된 accessToken이 반환되어야 함")
        #expect(result.refreshToken == refreshedTokens.refreshToken, "갱신된 refreshToken이 반환되어야 함")
        AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedRefreshCalls: 1)
    }

    @Test("TC-022: Logout 및 상태 초기화")
    func test_logout_and_state_reset() async throws {
        // Given: 로그아웃 성공 설정
        let logoutEntity = AuthTestFixture.successfulLogout
        mockAuthRepository.logoutResponse = .success(logoutEntity)
        mockKeychainManager.preloadTokens(accessToken: "stored_access", refreshToken: "stored_refresh")

        // When: 로그아웃 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager,
            mockUserSession: mockUserSession
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.logout()
        }

        // Then: 로그아웃 및 상태 초기화 검증
        #expect(result.code == logoutEntity.code, "로그아웃 응답이 올바르게 반환되어야 함")
        #expect(result.message == logoutEntity.message, "로그아웃 메시지가 올바르게 반환되어야 함")

        AuthTestHelper.verifyKeychainCleared(mockKeychain: mockKeychainManager)
        AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLogoutCalls: 1)
    }

    // MARK: - Additional Test Methods

    @Test("TC-023: UpdateSessionCredential 호출 검증")
    func test_update_session_credential_call() async throws {
        // Given: 세션 자격증명 업데이트 토큰
        let testTokens = AuthTestFixture.validAuthTokens

        // When: 세션 자격증명 업데이트 실행
        try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            useCase.updateSessionCredential(with: testTokens)
        }

        // Then: Repository 호출 검증
        AuthTestHelper.verifyRepositoryCalls(
            mockRepository: mockAuthRepository,
            expectedUpdateCredentialCalls: 1
        )
        #expect(mockAuthRepository.lastUpdateTokens == testTokens, "올바른 토큰이 전달되어야 함")
    }

    @Test("TC-024: 회원탈퇴 성공")
    func test_withdraw_success() async throws {
        // Given: 회원탈퇴 성공 설정
        let withdrawToken = AuthTestFixture.TestTokens.withdrawToken
        let withdrawEntity = AuthTestFixture.successfulWithdraw
        mockAuthRepository.withdrawResponse = .success(withdrawEntity)
        mockKeychainManager.preloadTokens(accessToken: "stored_access", refreshToken: "stored_refresh")

        // When: 회원탈퇴 실행
        let result = try await AuthTestHelper.withMockDependencies(
            mockAuthRepository: mockAuthRepository,
            mockKeychainManager: mockKeychainManager
        ) {
            let useCase = AuthUseCaseImpl()
            return try await useCase.withDraw(token: withdrawToken)
        }

        // Then: 회원탈퇴 성공 검증
        #expect(result.isSuccess, "회원탈퇴가 성공해야 함")
        #expect(result.code == withdrawEntity.code, "탈퇴 응답 코드가 올바르게 반환되어야 함")

        AuthTestHelper.verifyKeychainCleared(mockKeychain: mockKeychainManager)
        AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedWithdrawCalls: 1)
        #expect(mockAuthRepository.lastWithdrawToken == withdrawToken, "올바른 토큰이 전달되어야 함")
    }

    @Test("TC-025: 회원탈퇴 실패")
    func test_withdraw_failure() async throws {
        // Given: 회원탈퇴 실패 설정
        mockAuthRepository.configureWithdrawFailure(AuthError.unauthorized)

        // When & Then: 회원탈퇴 실패 검증
        await #expect(throws: AuthError.self) {
            try await AuthTestHelper.withMockDependencies(
                mockAuthRepository: mockAuthRepository,
                mockKeychainManager: mockKeychainManager
            ) {
                let useCase = AuthUseCaseImpl()
                _ = try await useCase.withDraw(token: AuthTestFixture.TestTokens.withdrawToken)
            }
        }

        // Then: 실패 시 Keychain은 정리되지 않아야 함
        #expect(mockKeychainManager.clearCallCount == 0, "실패 시 Keychain이 정리되지 않아야 함")
    }
}

// MARK: - Test Tags
extension Tag {
    @Tag static var unit: Self
    @Tag static var auth: Self
    @Tag static var integration: Self
    @Tag static var performance: Self
}