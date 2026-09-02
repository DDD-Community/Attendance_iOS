//
//  AuthDependencyContractTests.swift
//  DomainInterfaceTests
//
//  Created by DDD on 2026-09-02.
//

import Testing

import Entity
@testable import DomainInterface

@Suite("Auth Dependency Contract")
struct AuthDependencyContractTests {
  @Test("MockAuthRepository success는 로그인 결과와 호출 횟수를 기록한다")
  func mockAuthRepositorySuccessRecordsLoginCall() async throws {
    let repository = MockAuthRepository.success()

    let entity = try await repository.login(provider: .google, token: "google-token")

    #expect(entity.name == "Google User")
    #expect(entity.provider == .google)
    #expect(entity.isNewUser == false)
    #expect(entity.token.accessToken == "mock-access-token")
    #expect(repository.getLoginCallCount() == 1)
  }

  @Test("MockAuthRepository invalidToken은 typed AuthError.invalidCredential을 던진다")
  func mockAuthRepositoryInvalidTokenThrowsTypedError() async {
    let repository = MockAuthRepository.invalidToken()

    await #expect(throws: AuthError.invalidCredential("Mock invalid token")) {
      try await repository.login(provider: .google, token: "invalid-token")
    }
  }

  @Test("MockAuthRepository tokenExpired는 refreshTokenExpired를 던진다")
  func mockAuthRepositoryExpiredRefreshThrowsTypedError() async {
    let repository = MockAuthRepository.tokenExpired()

    await #expect(throws: AuthError.refreshTokenExpired) {
      try await repository.refresh()
    }
  }

  @Test("MockKeychainManager success는 저장한 토큰을 다시 반환한다")
  func mockKeychainManagerReturnsSavedTokens() {
    let keychain = MockKeychainManager.success()

    keychain.save(accessToken: "access-token", refreshToken: "refresh-token")

    #expect(keychain.accessToken() == "access-token")
    #expect(keychain.refreshToken() == "refresh-token")
    #expect(keychain.getSaveCallCount() == 1)
    #expect(keychain.getGetCallCount() == 2)
  }

  @Test("MockKeychainManager clear는 저장된 토큰을 제거한다")
  func mockKeychainManagerClearRemovesTokens() {
    let keychain = MockKeychainManager.success()
    keychain.save(accessToken: "access-token", refreshToken: "refresh-token")

    keychain.clear()

    #expect(keychain.getStoredAccessToken() == nil)
    #expect(keychain.getStoredRefreshToken() == nil)
    #expect(keychain.getClearCallCount() == 1)
  }
}
