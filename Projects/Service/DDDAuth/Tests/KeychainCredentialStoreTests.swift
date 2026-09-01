//
//  KeychainCredentialStoreTests.swift
//  DDDAuthTests
//
//  Created by DDD on 9/1/26.
//

import DDDStorageInterface
import Testing
@testable import DDDAuth

struct KeychainCredentialStoreTests {
  @Test
  func secureStorage의_토큰쌍을_credential로_읽는다() throws {
    let storage = FakeSecureStorage(values: [
      .accessToken: "access",
      .refreshToken: "refresh"
    ])

    let credential = try #require(KeychainCredentialStore(storage: storage).load())

    #expect(credential.accessToken == "access")
    #expect(credential.refreshToken == "refresh")
  }

  @Test
  func 토큰_한쪽이_없으면_로그아웃_상태로_판단한다() {
    let storage = FakeSecureStorage(values: [.accessToken: "access"])

    #expect(KeychainCredentialStore(storage: storage).load() == nil)
  }

  @Test
  func clear는_인증토큰을_모두_삭제한다() {
    let storage = FakeSecureStorage(values: [
      .accessToken: "access",
      .refreshToken: "refresh"
    ])
    let sut = KeychainCredentialStore(storage: storage)

    sut.clear()

    #expect(storage.values.isEmpty)
  }
}
