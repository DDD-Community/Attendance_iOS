//
//  AuthTestHelper.swift
//  UseCaseTests
//
//  Created by TDD AI Automation on 2026-01-31
//

import Foundation
import Testing
import Entity
import ComposableArchitecture
@testable import UseCase

// MARK: - Auth Test Helper
@MainActor
public struct AuthTestHelper {

    // MARK: - Dependency Setup
    public static func withMockDependencies<T>(
        mockAuthRepository: MockAuthRepository = MockAuthRepository(),
        mockKeychainManager: MockKeychainManager = MockKeychainManager(),
        mockUserSession: MockUserSession = MockUserSession(),
        operation: @MainActor () async throws -> T
    ) async rethrows -> T {

        return try await withDependencies {
            $0.authRepository = mockAuthRepository
            $0.keychainManager = mockKeychainManager
        } operation: {
            try await operation()
        }
    }

    // MARK: - Test State Management
    public static func createTestAuthUseCase(
        with mockRepository: MockAuthRepository,
        and mockKeychain: MockKeychainManager,
        initialStaffRole: Staff? = nil,
        initialUserSession: UserSession = .empty
    ) -> (AuthUseCaseImpl, MockAuthRepository, MockKeychainManager) {

        return withDependencies {
            $0.authRepository = mockRepository
            $0.keychainManager = mockKeychain
        } operation: {
            let useCase = AuthUseCaseImpl()
            return (useCase, mockRepository, mockKeychain)
        }
    }

    // MARK: - Assertion Helpers
    public static func verifyLoginSuccess(
        result: LoginEntity,
        expectedProvider: SocialType,
        expectedName: String,
        expectedIsNewUser: Bool,
        expectedRole: Staff?,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(result.provider == expectedProvider,
               "Provider should be \(expectedProvider.rawValue), got \(result.provider.rawValue)",
               sourceLocation: sourceLocation)

        #expect(result.name == expectedName,
               "Name should be '\(expectedName)', got '\(result.name)'",
               sourceLocation: sourceLocation)

        #expect(result.isNewUser == expectedIsNewUser,
               "IsNewUser should be \(expectedIsNewUser), got \(result.isNewUser)",
               sourceLocation: sourceLocation)

        #expect(result.role == expectedRole,
               "Role should be \(String(describing: expectedRole)), got \(String(describing: result.role))",
               sourceLocation: sourceLocation)
    }

    public static func verifyTokenStorage(
        mockKeychain: MockKeychainManager,
        expectedAccessToken: String,
        expectedRefreshToken: String,
        shouldBeCalled: Bool = true,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        if shouldBeCalled {
            #expect(mockKeychain.saveCallCount > 0,
                   "Keychain save should have been called",
                   sourceLocation: sourceLocation)

            #expect(mockKeychain.verifyTokensSaved(
                accessToken: expectedAccessToken,
                refreshToken: expectedRefreshToken
            ), "Tokens should match expected values", sourceLocation: sourceLocation)
        } else {
            #expect(mockKeychain.saveCallCount == 0,
                   "Keychain save should not have been called",
                   sourceLocation: sourceLocation)
        }
    }

    public static func verifyKeychainCleared(
        mockKeychain: MockKeychainManager,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(mockKeychain.clearCallCount > 0,
               "Keychain clear should have been called",
               sourceLocation: sourceLocation)

        #expect(mockKeychain.isCleared,
               "Keychain should be cleared",
               sourceLocation: sourceLocation)
    }

    // MARK: - UserSession Verification
    public static func verifyUserSessionUpdated(
        mockSession: MockUserSession,
        expectedOAuthToken: String?,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(mockSession.wasSessionUpdated(),
               "UserSession should have been updated",
               sourceLocation: sourceLocation)

        #expect(mockSession.verifyOAuthRefreshToken(expectedOAuthToken),
               "OAuth refresh token should match expected value",
               sourceLocation: sourceLocation)
    }

    public static func verifyStaffRoleCleared(
        mockSession: MockUserSession,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(mockSession.wasStaffRoleUpdated(),
               "Staff role should have been updated",
               sourceLocation: sourceLocation)

        #expect(mockSession.staffRole == nil,
               "Staff role should be nil after logout",
               sourceLocation: sourceLocation)
    }

    // MARK: - Error Verification
    public static func verifyError<T: Error & Equatable>(
        _ error: Error,
        expectedError: T,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard let actualError = error as? T else {
            Issue.record("Error type mismatch. Expected \(T.self), got \(type(of: error))",
                        sourceLocation: sourceLocation)
            return
        }

        #expect(actualError == expectedError,
               "Error should be \(expectedError), got \(actualError)",
               sourceLocation: sourceLocation)
    }

    // MARK: - Repository Call Verification
    public static func verifyRepositoryCalls(
        mockRepository: MockAuthRepository,
        expectedLoginCalls: Int = 0,
        expectedRefreshCalls: Int = 0,
        expectedLogoutCalls: Int = 0,
        expectedWithdrawCalls: Int = 0,
        expectedUpdateCredentialCalls: Int = 0,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(mockRepository.loginCallCount == expectedLoginCalls,
               "Login call count should be \(expectedLoginCalls), got \(mockRepository.loginCallCount)",
               sourceLocation: sourceLocation)

        #expect(mockRepository.refreshCallCount == expectedRefreshCalls,
               "Refresh call count should be \(expectedRefreshCalls), got \(mockRepository.refreshCallCount)",
               sourceLocation: sourceLocation)

        #expect(mockRepository.logoutCallCount == expectedLogoutCalls,
               "Logout call count should be \(expectedLogoutCalls), got \(mockRepository.logoutCallCount)",
               sourceLocation: sourceLocation)

        #expect(mockRepository.withDrawCallCount == expectedWithdrawCalls,
               "Withdraw call count should be \(expectedWithdrawCalls), got \(mockRepository.withDrawCallCount)",
               sourceLocation: sourceLocation)

        #expect(mockRepository.updateSessionCredentialCallCount == expectedUpdateCredentialCalls,
               "Update credential call count should be \(expectedUpdateCredentialCalls), got \(mockRepository.updateSessionCredentialCallCount)",
               sourceLocation: sourceLocation)
    }

    // MARK: - Concurrent Testing Helpers
    public static func performConcurrentOperations<T>(
        operations: [() async throws -> T],
        timeout: TimeInterval = 5.0
    ) async throws -> [Result<T, Error>] {
        return await withThrowingTaskGroup(of: Result<T, Error>.self) { group in
            var results: [Result<T, Error>] = []

            for operation in operations {
                group.addTask {
                    do {
                        let result = try await operation()
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            for await result in group {
                results.append(result)
            }

            return results
        }
    }

    // MARK: - Test Data Validation
    public static func validateAuthTokens(
        _ tokens: AuthTokens,
        shouldHaveOAuthToken: Bool,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(!tokens.accessToken.isEmpty,
               "Access token should not be empty",
               sourceLocation: sourceLocation)

        #expect(!tokens.refreshToken.isEmpty,
               "Refresh token should not be empty",
               sourceLocation: sourceLocation)

        if shouldHaveOAuthToken {
            #expect(tokens.oauthRefreshToken != nil,
                   "OAuth refresh token should not be nil for providers that support it",
                   sourceLocation: sourceLocation)
        } else {
            #expect(tokens.oauthRefreshToken == nil,
                   "OAuth refresh token should be nil for Apple provider",
                   sourceLocation: sourceLocation)
        }
    }

    // MARK: - Time-based Testing
    public static func measureExecutionTime<T>(
        of operation: () async throws -> T
    ) async rethrows -> (result: T, duration: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        return (result, duration)
    }

    // MARK: - Mock Reset Utilities
    public static func resetAllMocks(
        repository: MockAuthRepository,
        keychain: MockKeychainManager,
        userSession: MockUserSession
    ) {
        repository.reset()
        keychain.reset()
        userSession.reset()
    }
}