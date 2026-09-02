//
//  CoreAssemblyTests.swift
//  CoreAssemblyTests
//
//  Created by DDD on 2026-09-02
//

import DDDNetworkInterface
import DDDStorageInterface
import Testing

@testable import CoreAssembly

@Suite("CoreAssembly")
struct CoreAssemblyTests {
  @Test("plainClient는 DDDNetworkClient 구현을 제공한다")
  func plainClientProvidesNetworkClient() {
    let client: any DDDNetworkClient = NetworkAssembly.plainClient()

    #expect(String(describing: type(of: client)).isEmpty == false)
  }

  @Test("secureStorage는 SecureStorage 구현을 제공한다")
  func secureStorageProvidesStorage() {
    let storage: any SecureStorage = StorageAssembly.secureStorage()

    #expect(String(describing: type(of: storage)).isEmpty == false)
  }
}
