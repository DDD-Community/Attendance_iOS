//
//  DomainAssemblyTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 2026-09-02
//

import Testing

@testable import DomainAssembly

@Suite("DomainAssembly")
struct DomainAssemblyTests {
  @Test("DomainAssembly는 Entity 타입을 재수출한다")
  func reexportsEntityTypes() {
    let type = SocialType.apple

    #expect(type.description == "APPLE")
  }

  @Test("DomainAssembly는 DomainInterface mock을 재수출한다")
  func reexportsDomainInterfaceMocks() async throws {
    let repository = MockAuthRepository.success()
    let entity = try await repository.login(provider: .apple, token: "token")

    #expect(entity.provider == .apple)
  }
}
