//
//  AuthDependencyContractTests.swift
//  DomainInterfaceTests
//
//  Created by DDD on 2026-09-02.
//

import Testing

@testable import AuthDomainInterface

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

}
