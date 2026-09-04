//
//  AuthInterfaceContractTests.swift
//  DomainInterfaceTests
//
//  Created by DDD on 9/2/26.
//

import Testing

@testable import AuthDomainInterface

@MainActor
struct DomainInterfaceContractTests {
  @Test("Auth 기본 목은 토큰 만료를 typed AuthError로 노출한다")
  func authMockExposesRefreshTokenExpiredError() async {
    let repository: AuthInterface = MockAuthRepository.tokenExpired()

    await #expect(throws: AuthError.refreshTokenExpired) {
      try await repository.refresh()
    }
  }
}
