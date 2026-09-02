//
//  DomainInterfaceContractTests.swift
//  DomainInterfaceTests
//
//  Created by DDD on 9/2/26.
//

import Entity
import Testing

@testable import DomainInterface

struct DomainInterfaceContractTests {
  @Test("키체인 테스트 더블은 저장한 access refresh token을 반환한다")
  func keychainDoubleReturnsSavedTokens() {
    let keychain = MockKeychainManager()

    keychain.save(accessToken: "access", refreshToken: "refresh")

    #expect(keychain.accessToken() == "access")
    #expect(keychain.refreshToken() == "refresh")
  }

  @Test("Auth 기본 목은 토큰 만료를 typed AuthError로 노출한다")
  func authMockExposesRefreshTokenExpiredError() async {
    let repository: AuthInterface = MockAuthRepository.tokenExpired()

    await #expect(throws: AuthError.refreshTokenExpired) {
      try await repository.refresh()
    }
  }
}
