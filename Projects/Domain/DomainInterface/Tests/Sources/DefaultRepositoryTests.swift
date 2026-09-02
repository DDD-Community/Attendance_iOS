//
//  DefaultRepositoryTests.swift
//  DomainInterfaceTests
//
//  Created by DDD on 2026-09-02
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//

import Entity
import Testing

@testable import DomainInterface

@Suite("DomainInterface Default Repository")
struct DefaultRepositoryTests {
  @Test("DefaultAuthRepositoryImpl 로그인은 요청 provider를 그대로 보존한다")
  func defaultAuthLoginKeepsProvider() async throws {
    let repository = DefaultAuthRepositoryImpl()

    let entity = try await repository.login(provider: .google, token: "token")

    #expect(entity.provider == .google)
    #expect(entity.role == .member)
    #expect(entity.token.accessToken.isEmpty == false)
  }

  @Test("DefaultAppUpdateRepositoryImpl은 업데이트 없음 상태를 반환한다")
  func defaultAppUpdateReportsNoUpdate() async throws {
    let repository = DefaultAppUpdateRepositoryImpl()

    let info = try await repository.checkForUpdate()

    #expect(info.isUpdateAvailable == false)
    #expect(info.appStoreUrl.isEmpty == false)
  }
}
