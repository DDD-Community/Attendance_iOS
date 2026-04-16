//
//  ManagerUseCaseTest.swift
//  UseCaseTests
//
//  Created by TDD AI Automation on 2026-04-16
//

import Testing
import Foundation
import ComposableArchitecture
@testable import UseCase
@testable import Entity
@testable import DomainInterface

@Suite("Manager UseCase Tests - Complete TDD Implementation", .tags(.unit, .manager))
@MainActor
struct ManagerUseCaseTest {

    // MARK: - Test Dependencies
    private var mockKeychainManager: MockKeychainManagerForTest!

    init() async {
        mockKeychainManager = MockKeychainManagerForTest()
    }

    // MARK: - Core Manager Tests (12 Test Cases)

    @Test("TC-001: 토큰 저장 성공")
    func test_save_tokens_success() async throws {
        // Given: 토큰 저장을 위한 KeychainManager
        let accessToken = "test_access_token_123"
        let refreshToken = "test_refresh_token_456"

        // When: 토큰 저장 실행
        let result = await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            manager.save(accessToken: accessToken, refreshToken: refreshToken)
            return (manager.accessToken(), manager.refreshToken())
        }

        // Then: 토큰 저장 검증
        // Note: KeychainManager는 실제 시스템 Keychain을 사용하므로 Mock을 통한 검증
        #expect(mockKeychainManager.saveCallCount == 1, "save 메서드가 호출되어야 함")
        #expect(mockKeychainManager.lastSavedAccessToken == accessToken, "올바른 access token이 저장되어야 함")
        #expect(mockKeychainManager.lastSavedRefreshToken == refreshToken, "올바른 refresh token이 저장되어야 함")
    }

    @Test("TC-002: 개별 토큰 저장 성공")
    func test_save_individual_tokens_success() async throws {
        // Given: 개별 토큰 저장을 위한 설정
        let accessToken = "individual_access_123"
        let refreshToken = "individual_refresh_456"

        // When: 개별 토큰 저장 실행
        await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            manager.saveAccessToken(accessToken)
            manager.saveRefreshToken(refreshToken)
        }

        // Then: 개별 토큰 저장 검증
        #expect(mockKeychainManager.saveAccessTokenCallCount == 1, "saveAccessToken이 호출되어야 함")
        #expect(mockKeychainManager.saveRefreshTokenCallCount == 1, "saveRefreshToken이 호출되어야 함")
        #expect(mockKeychainManager.lastSavedAccessToken == accessToken, "올바른 access token이 저장되어야 함")
        #expect(mockKeychainManager.lastSavedRefreshToken == refreshToken, "올바른 refresh token이 저장되어야 함")
    }

    @Test("TC-003: 토큰 조회 성공")
    func test_retrieve_tokens_success() async throws {
        // Given: 저장된 토큰이 있는 상태 설정
        let storedAccessToken = "stored_access_789"
        let storedRefreshToken = "stored_refresh_012"
        mockKeychainManager.preloadTokens(accessToken: storedAccessToken, refreshToken: storedRefreshToken)

        // When: 토큰 조회 실행
        let result = await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            return (manager.accessToken(), manager.refreshToken())
        }

        // Then: 토큰 조회 검증
        #expect(result.0 == storedAccessToken, "올바른 access token이 조회되어야 함")
        #expect(result.1 == storedRefreshToken, "올바른 refresh token이 조회되어야 함")
        #expect(mockKeychainManager.accessTokenCallCount >= 1, "accessToken 조회가 호출되어야 함")
        #expect(mockKeychainManager.refreshTokenCallCount >= 1, "refreshToken 조회가 호출되어야 함")
    }

    @Test("TC-004: 토큰 조회 실패 (토큰 없음)")
    func test_retrieve_tokens_not_found() async throws {
        // Given: 토큰이 없는 상태 설정
        mockKeychainManager.configureTokensNotFound()

        // When: 토큰 조회 실행
        let result = await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            return (manager.accessToken(), manager.refreshToken())
        }

        // Then: 토큰 없음 검증
        #expect(result.0 == nil, "토큰이 없으면 nil이 반환되어야 함")
        #expect(result.1 == nil, "토큰이 없으면 nil이 반환되어야 함")
        #expect(mockKeychainManager.accessTokenCallCount >= 1, "accessToken 조회가 시도되어야 함")
        #expect(mockKeychainManager.refreshTokenCallCount >= 1, "refreshToken 조회가 시도되어야 함")
    }

    @Test("TC-005: 토큰 삭제 성공")
    func test_clear_tokens_success() async throws {
        // Given: 저장된 토큰이 있는 상태
        mockKeychainManager.preloadTokens(accessToken: "to_be_deleted_access", refreshToken: "to_be_deleted_refresh")

        // When: 토큰 삭제 실행
        await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            manager.clear()
        }

        // Then: 토큰 삭제 검증
        #expect(mockKeychainManager.clearCallCount == 1, "clear 메서드가 호출되어야 함")
        #expect(!mockKeychainManager.hasStoredTokens, "토큰이 삭제되어야 함")
    }

    @Test("TC-006: 빈 토큰 저장 처리")
    func test_save_empty_tokens() async throws {
        // Given: 빈 토큰 문자열
        let emptyAccessToken = ""
        let emptyRefreshToken = ""

        // When: 빈 토큰 저장 실행
        await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            manager.save(accessToken: emptyAccessToken, refreshToken: emptyRefreshToken)
        }

        // Then: 빈 토큰 저장 검증
        #expect(mockKeychainManager.lastSavedAccessToken == "", "빈 access token이 저장되어야 함")
        #expect(mockKeychainManager.lastSavedRefreshToken == "", "빈 refresh token이 저장되어야 함")
        #expect(mockKeychainManager.saveCallCount == 1, "save가 호출되어야 함")
    }

    @Test("TC-007: 매우 긴 토큰 저장 처리")
    func test_save_long_tokens() async throws {
        // Given: 매우 긴 토큰 (1000자)
        let longAccessToken = String(repeating: "a", count: 1000)
        let longRefreshToken = String(repeating: "r", count: 1000)

        // When: 긴 토큰 저장 실행
        await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            manager.save(accessToken: longAccessToken, refreshToken: longRefreshToken)
        }

        // Then: 긴 토큰 저장 검증
        #expect(mockKeychainManager.lastSavedAccessToken?.count == 1000, "긴 access token이 저장되어야 함")
        #expect(mockKeychainManager.lastSavedRefreshToken?.count == 1000, "긴 refresh token이 저장되어야 함")
        #expect(mockKeychainManager.saveCallCount == 1, "save가 호출되어야 함")
    }

    @Test("TC-008: 특수 문자 포함 토큰 처리")
    func test_save_tokens_with_special_characters() async throws {
        // Given: 특수 문자가 포함된 토큰
        let specialAccessToken = "access.token-with_special!@#$%^&*()characters"
        let specialRefreshToken = "refresh+token=with/special?characters&more"

        // When: 특수 문자 토큰 저장 실행
        await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            manager.save(accessToken: specialAccessToken, refreshToken: specialRefreshToken)
        }

        // Then: 특수 문자 토큰 저장 검증
        #expect(mockKeychainManager.lastSavedAccessToken == specialAccessToken, "특수 문자 access token이 저장되어야 함")
        #expect(mockKeychainManager.lastSavedRefreshToken == specialRefreshToken, "특수 문자 refresh token이 저장되어야 함")
        #expect(mockKeychainManager.saveCallCount == 1, "save가 호출되어야 함")
    }

    @Test("TC-009: 토큰 업데이트 처리")
    func test_token_update_handling() async throws {
        // Given: 기존 토큰이 있는 상태
        let oldAccessToken = "old_access_token"
        let oldRefreshToken = "old_refresh_token"
        let newAccessToken = "new_access_token"
        let newRefreshToken = "new_refresh_token"

        mockKeychainManager.preloadTokens(accessToken: oldAccessToken, refreshToken: oldRefreshToken)

        // When: 토큰 업데이트 실행
        await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            manager.save(accessToken: newAccessToken, refreshToken: newRefreshToken)
        }

        // Then: 토큰 업데이트 검증
        #expect(mockKeychainManager.lastSavedAccessToken == newAccessToken, "새로운 access token으로 업데이트되어야 함")
        #expect(mockKeychainManager.lastSavedRefreshToken == newRefreshToken, "새로운 refresh token으로 업데이트되어야 함")
        #expect(mockKeychainManager.saveCallCount == 1, "업데이트가 호출되어야 함")
    }

    @Test("TC-010: 부분 토큰 업데이트")
    func test_partial_token_update() async throws {
        // Given: 기존 토큰이 있는 상태
        mockKeychainManager.preloadTokens(accessToken: "existing_access", refreshToken: "existing_refresh")

        // When: Access Token만 업데이트
        let newAccessToken = "updated_access_only"
        await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            let manager = KeychainManager()
            manager.saveAccessToken(newAccessToken)
        }

        // Then: 부분 업데이트 검증
        #expect(mockKeychainManager.lastSavedAccessToken == newAccessToken, "access token만 업데이트되어야 함")
        #expect(mockKeychainManager.saveAccessTokenCallCount == 1, "saveAccessToken이 호출되어야 함")
        #expect(mockKeychainManager.saveRefreshTokenCallCount == 0, "saveRefreshToken은 호출되지 않아야 함")
    }

    @Test("TC-011: KeychainManager 인스턴스 격리")
    func test_keychain_manager_instance_isolation() async throws {
        // Given: 서로 다른 service를 가진 KeychainManager 인스턴스들
        let manager1 = KeychainManager(service: "service1")
        let manager2 = KeychainManager(service: "service2")

        // When: 각각에 다른 토큰 저장
        await withDependencies {
            $0.keychainManager = mockKeychainManager
        } operation: {
            manager1.save(accessToken: "manager1_access", refreshToken: "manager1_refresh")
            manager2.save(accessToken: "manager2_access", refreshToken: "manager2_refresh")
        }

        // Then: 인스턴스 격리 확인 (실제로는 service가 다르므로 분리됨)
        // Mock을 통해서는 격리를 완전히 테스트할 수 없지만, 호출은 확인 가능
        #expect(mockKeychainManager.saveCallCount >= 2, "두 개의 save 호출이 있어야 함")
    }

    @Test("TC-012: 동시 토큰 접근 처리")
    func test_concurrent_token_access() async throws {
        // Given: 동시 접근을 위한 토큰 설정
        let testAccessToken = "concurrent_access_token"
        let testRefreshToken = "concurrent_refresh_token"
        mockKeychainManager.preloadTokens(accessToken: testAccessToken, refreshToken: testRefreshToken)

        // When: 5개의 동시 토큰 조회 요청
        let results = try await withTaskGroup(of: (String?, String?).self, returning: [(String?, String?)].self) { group in
            for _ in 1...5 {
                group.addTask {
                    await withDependencies {
                        $0.keychainManager = mockKeychainManager
                    } operation: {
                        let manager = KeychainManager()
                        return (manager.accessToken(), manager.refreshToken())
                    }
                }
            }

            var results: [(String?, String?)] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }

        // Then: 동시 접근 결과 검증
        #expect(results.count == 5, "모든 동시 요청이 완료되어야 함")
        #expect(results.allSatisfy { $0.0 == testAccessToken }, "모든 요청이 동일한 access token을 반환해야 함")
        #expect(results.allSatisfy { $0.1 == testRefreshToken }, "모든 요청이 동일한 refresh token을 반환해야 함")
        #expect(mockKeychainManager.accessTokenCallCount >= 5, "access token 조회가 여러 번 호출되어야 함")
        #expect(mockKeychainManager.refreshTokenCallCount >= 5, "refresh token 조회가 여러 번 호출되어야 함")
    }
}

// MARK: - Mock KeychainManager for Test
class MockKeychainManagerForTest: KeychainManaging {

    // MARK: - Call Tracking
    var saveCallCount = 0
    var saveAccessTokenCallCount = 0
    var saveRefreshTokenCallCount = 0
    var accessTokenCallCount = 0
    var refreshTokenCallCount = 0
    var clearCallCount = 0

    // MARK: - Stored Data
    var lastSavedAccessToken: String?
    var lastSavedRefreshToken: String?
    private var storedAccessToken: String?
    private var storedRefreshToken: String?
    private var tokensNotFound = false

    // MARK: - Computed Properties
    var hasStoredTokens: Bool {
        return storedAccessToken != nil || storedRefreshToken != nil
    }

    // MARK: - Implementation
    func save(accessToken: String, refreshToken: String) {
        saveCallCount += 1
        lastSavedAccessToken = accessToken
        lastSavedRefreshToken = refreshToken
        storedAccessToken = accessToken
        storedRefreshToken = refreshToken
    }

    func saveAccessToken(_ token: String) {
        saveAccessTokenCallCount += 1
        lastSavedAccessToken = token
        storedAccessToken = token
    }

    func saveRefreshToken(_ token: String) {
        saveRefreshTokenCallCount += 1
        lastSavedRefreshToken = token
        storedRefreshToken = token
    }

    func accessToken() -> String? {
        accessTokenCallCount += 1
        return tokensNotFound ? nil : storedAccessToken
    }

    func refreshToken() -> String? {
        refreshTokenCallCount += 1
        return tokensNotFound ? nil : storedRefreshToken
    }

    func clear() {
        clearCallCount += 1
        storedAccessToken = nil
        storedRefreshToken = nil
        lastSavedAccessToken = nil
        lastSavedRefreshToken = nil
    }

    // MARK: - Configuration Methods
    func preloadTokens(accessToken: String, refreshToken: String) {
        storedAccessToken = accessToken
        storedRefreshToken = refreshToken
        tokensNotFound = false
    }

    func configureTokensNotFound() {
        tokensNotFound = true
        storedAccessToken = nil
        storedRefreshToken = nil
    }
}

// MARK: - Test Tags
extension Tag {
    @Tag static var unit: Self
    @Tag static var manager: Self
}