//
//  DDDCoreUtilityTests.swift
//  DDDCoreUtility
//
//  모듈이 링크되는지 확인하는 스모크 테스트.
//  이 타깃이 있어야 tuist test 가 모듈을 실행해 커버리지가 집계된다.
//

import Testing

@testable import DDDCoreUtility

@Suite("DDDCoreUtility 스모크")
struct DDDCoreUtilityTests {
  @Test("모듈이 링크된다")
  func moduleLinks() {
    #expect(Bool(true))
  }
}
