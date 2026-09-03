//
//  MockRepositoryTests.swift
//  DomainInterfaceTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import Testing

@testable import AppUpdateDomainInterface
@testable import AuthDomainInterface

@Suite("Domain Interface Mock Repository")
struct MockRepositoryTests {
  @Test("MockAuthRepository 로그인은 요청 provider를 그대로 보존한다")
  func mockAuthLoginKeepsProvider() async throws {
    let repository = MockAuthRepository()

    let entity = try await repository.login(provider: .google, token: "token")

    #expect(entity.provider == .google)
    #expect(entity.role == .member)
    #expect(entity.token.accessToken.isEmpty == false)
  }

  @Test("MockAppUpdateRepository은 업데이트 없음 상태를 반환한다")
  func mockAppUpdateReportsNoUpdate() async throws {
    let repository = MockAppUpdateRepository()

    let info = try await repository.checkForUpdate()

    #expect(info.isUpdateAvailable == false)
    #expect(info.appStoreUrl.isEmpty == false)
  }
}
