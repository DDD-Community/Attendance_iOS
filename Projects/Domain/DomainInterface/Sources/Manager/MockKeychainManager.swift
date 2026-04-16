//
//  MockKeychainManager.swift
//  DomainInterface
//
//  Created by TDD Automation on 2026-04-16
//

import Foundation

public actor MockKeychainManager: KeychainManaging {
    // MARK: - Configuration
    public enum Configuration {
        case success
        case failure
        case saveFailure
        case getFailure
    }

    // MARK: - State
    private var configuration: Configuration = .success
    private var saveCallCount = 0
    private var getCallCount = 0
    private var clearCallCount = 0
    private var storedAccessToken: String?
    private var storedRefreshToken: String?

    // MARK: - Public Configuration Methods
    public init(configuration: Configuration = .success) {
        self.configuration = configuration
    }

    public static func success() -> MockKeychainManager {
        MockKeychainManager(configuration: .success)
    }

    public static func failure() -> MockKeychainManager {
        MockKeychainManager(configuration: .failure)
    }

    public static func saveFailure() -> MockKeychainManager {
        MockKeychainManager(configuration: .saveFailure)
    }

    public static func getFailure() -> MockKeychainManager {
        MockKeychainManager(configuration: .getFailure)
    }

    // MARK: - Call Count Getters
    public func getSaveCallCount() -> Int { saveCallCount }
    public func getGetCallCount() -> Int { getCallCount }
    public func getClearCallCount() -> Int { clearCallCount }
    public func getStoredAccessToken() -> String? { storedAccessToken }
    public func getStoredRefreshToken() -> String? { storedRefreshToken }

    // MARK: - KeychainManaging Implementation

    public func save(accessToken: String, refreshToken: String) {
        saveCallCount += 1

        switch configuration {
        case .success:
            storedAccessToken = accessToken
            storedRefreshToken = refreshToken
        case .saveFailure, .failure:
            // 저장 실패 시뮬레이션 (실제로는 저장하지 않음)
            break
        default:
            storedAccessToken = accessToken
            storedRefreshToken = refreshToken
        }
    }

    public func getAccessToken() -> String? {
        getCallCount += 1

        switch configuration {
        case .success:
            return storedAccessToken ?? "mock-stored-access-token"
        case .getFailure, .failure:
            return nil
        default:
            return storedAccessToken
        }
    }

    public func getRefreshToken() -> String? {
        getCallCount += 1

        switch configuration {
        case .success:
            return storedRefreshToken ?? "mock-stored-refresh-token"
        case .getFailure, .failure:
            return nil
        default:
            return storedRefreshToken
        }
    }

    public func clear() {
        clearCallCount += 1

        switch configuration {
        case .success:
            storedAccessToken = nil
            storedRefreshToken = nil
        case .failure:
            // 클리어 실패 시뮬레이션 (실제로는 클리어하지 않음)
            break
        default:
            storedAccessToken = nil
            storedRefreshToken = nil
        }
    }

    public func reset() {
        configuration = .success
        saveCallCount = 0
        getCallCount = 0
        clearCallCount = 0
        storedAccessToken = nil
        storedRefreshToken = nil
    }
}