//
//  StorageFactoryTests.swift
//  DDDStorageTests
//
//  Created by DDD on 9/1/26.
//

import DDDStorageInterface
import Testing
@testable import DDDStorage

@Suite("StorageFactory")
struct StorageFactoryTests {
  @Test
  func secureStorage를_생성한다() {
    let storage: any SecureStorage = StorageFactory.secureStorage

    #expect(String(describing: type(of: storage)) == "KeychainStorage")
  }
}

@Suite("SecureStorageKey")
struct SecureStorageKeyTests {
  @Test
  func 기존_토큰_키_문자열을_유지한다() {
    #expect(SecureStorageKey.accessToken.rawValue == "ACCESS_TOKEN")
    #expect(SecureStorageKey.refreshToken.rawValue == "REFRESH_TOKEN")
  }

  @Test
  func 전체_삭제_대상에는_모든_토큰_키가_한번씩_포함된다() {
    #expect(Set(SecureStorageKey.all) == [.accessToken, .refreshToken])
    #expect(SecureStorageKey.all.count == 2)
  }
}
