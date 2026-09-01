//
//  StorageFactoryTests.swift
//  DDDStorageTests
//
//  Created by DDD on 9/1/26.
//

import DDDStorageInterface
import Testing
@testable import DDDStorage

struct StorageFactoryTests {
  @Test
  func secureStorage를_생성한다() {
    let storage: any SecureStorage = StorageFactory.secureStorage

    #expect(String(describing: type(of: storage)) == "KeychainStorage")
  }
}
