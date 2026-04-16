//
//  MockKeychainManager.swift
//  UseCaseTests
//
//  Created by TDD AI Automation on 2026-01-31
//

import Foundation
import DomainInterface

@MainActor
public final class MockKeychainManager: KeychainManaging {

    // MARK: - Storage
    private var storedAccessToken: String?
    private var storedRefreshToken: String?

    // MARK: - Call Tracking
    private(set) var saveCallCount = 0
    private(set) var saveAccessTokenCallCount = 0
    private(set) var saveRefreshTokenCallCount = 0
    private(set) var accessTokenCallCount = 0
    private(set) var refreshTokenCallCount = 0
    private(set) var clearCallCount = 0

    private(set) var lastSavedAccessToken: String?
    private(set) var lastSavedRefreshToken: String?

    // MARK: - Error Simulation
    public var shouldFailOnSave: Bool = false
    public var shouldFailOnRetrieve: Bool = false
    public var shouldReturnNilTokens: Bool = false

    public init() {}

    // MARK: - KeychainManaging Implementation
    public func save(accessToken: String, refreshToken: String) {
        saveCallCount += 1
        lastSavedAccessToken = accessToken
        lastSavedRefreshToken = refreshToken

        guard !shouldFailOnSave else { return }

        storedAccessToken = accessToken
        storedRefreshToken = refreshToken
    }

    public func saveAccessToken(_ token: String) {
        saveAccessTokenCallCount += 1
        lastSavedAccessToken = token

        guard !shouldFailOnSave else { return }

        storedAccessToken = token
    }

    public func saveRefreshToken(_ token: String) {
        saveRefreshTokenCallCount += 1
        lastSavedRefreshToken = token

        guard !shouldFailOnSave else { return }

        storedRefreshToken = token
    }

    public func accessToken() -> String? {
        accessTokenCallCount += 1

        if shouldFailOnRetrieve || shouldReturnNilTokens {
            return nil
        }

        return storedAccessToken
    }

    public func refreshToken() -> String? {
        refreshTokenCallCount += 1

        if shouldFailOnRetrieve || shouldReturnNilTokens {
            return nil
        }

        return storedRefreshToken
    }

    public func clear() {
        clearCallCount += 1
        storedAccessToken = nil
        storedRefreshToken = nil
    }

    // MARK: - Test Helpers
    public func reset() {
        // Clear stored data
        storedAccessToken = nil
        storedRefreshToken = nil

        // Reset call counts
        saveCallCount = 0
        saveAccessTokenCallCount = 0
        saveRefreshTokenCallCount = 0
        accessTokenCallCount = 0
        refreshTokenCallCount = 0
        clearCallCount = 0

        // Reset last saved values
        lastSavedAccessToken = nil
        lastSavedRefreshToken = nil

        // Reset error flags
        shouldFailOnSave = false
        shouldFailOnRetrieve = false
        shouldReturnNilTokens = false
    }

    public func preloadTokens(accessToken: String, refreshToken: String) {
        storedAccessToken = accessToken
        storedRefreshToken = refreshToken
    }

    // MARK: - Verification Helpers
    public var hasStoredTokens: Bool {
        return storedAccessToken != nil && storedRefreshToken != nil
    }

    public var isCleared: Bool {
        return storedAccessToken == nil && storedRefreshToken == nil
    }

    public func verifyTokensSaved(accessToken: String, refreshToken: String) -> Bool {
        return lastSavedAccessToken == accessToken && lastSavedRefreshToken == refreshToken
    }
}