import Foundation
import DomainInterface

@MainActor
final class MockKeychainManager: KeychainManaging {
  private var storedAccessToken: String?
  private var storedRefreshToken: String?

  private(set) var saveCallCount = 0
  private(set) var saveAccessTokenCallCount = 0
  private(set) var saveRefreshTokenCallCount = 0
  private(set) var accessTokenCallCount = 0
  private(set) var refreshTokenCallCount = 0
  private(set) var clearCallCount = 0

  private(set) var lastSavedAccessToken: String?
  private(set) var lastSavedRefreshToken: String?

  var shouldFailOnSave = false
  var shouldFailOnRetrieve = false
  var shouldReturnNilTokens = false

  func save(accessToken: String, refreshToken: String) {
    saveCallCount += 1
    lastSavedAccessToken = accessToken
    lastSavedRefreshToken = refreshToken
    guard !shouldFailOnSave else { return }
    storedAccessToken = accessToken
    storedRefreshToken = refreshToken
  }

  func saveAccessToken(_ token: String) {
    saveAccessTokenCallCount += 1
    lastSavedAccessToken = token
    guard !shouldFailOnSave else { return }
    storedAccessToken = token
  }

  func saveRefreshToken(_ token: String) {
    saveRefreshTokenCallCount += 1
    lastSavedRefreshToken = token
    guard !shouldFailOnSave else { return }
    storedRefreshToken = token
  }

  func accessToken() -> String? {
    accessTokenCallCount += 1
    return (shouldFailOnRetrieve || shouldReturnNilTokens) ? nil : storedAccessToken
  }

  func refreshToken() -> String? {
    refreshTokenCallCount += 1
    return (shouldFailOnRetrieve || shouldReturnNilTokens) ? nil : storedRefreshToken
  }

  func clear() {
    clearCallCount += 1
    storedAccessToken = nil
    storedRefreshToken = nil
  }

  func reset() {
    storedAccessToken = nil
    storedRefreshToken = nil
    saveCallCount = 0
    saveAccessTokenCallCount = 0
    saveRefreshTokenCallCount = 0
    accessTokenCallCount = 0
    refreshTokenCallCount = 0
    clearCallCount = 0
    lastSavedAccessToken = nil
    lastSavedRefreshToken = nil
    shouldFailOnSave = false
    shouldFailOnRetrieve = false
    shouldReturnNilTokens = false
  }

  func preloadTokens(accessToken: String, refreshToken: String) {
    storedAccessToken = accessToken
    storedRefreshToken = refreshToken
  }

  var hasStoredTokens: Bool { storedAccessToken != nil && storedRefreshToken != nil }
  var isCleared: Bool { storedAccessToken == nil && storedRefreshToken == nil }

  func verifyTokensSaved(accessToken: String, refreshToken: String) -> Bool {
    lastSavedAccessToken == accessToken && lastSavedRefreshToken == refreshToken
  }

  static func success() -> MockKeychainManager {
    MockKeychainManager()
  }

  func getSaveCallCount() -> Int { saveCallCount }
  func getClearCallCount() -> Int { clearCallCount }
  func getStoredAccessToken() -> String? { storedAccessToken }
  func getStoredRefreshToken() -> String? { storedRefreshToken }
}
