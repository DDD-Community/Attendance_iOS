//
//  DataAssemblyTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/2/26.
//

import Testing

@testable import AttendanceDomain
@testable import DomainAssembly

@Suite("Domain 컨텍스트 Data 조립")
struct DomainDataAssemblyTests {
  @Test("컨텍스트 Data 모델을 직접 사용할 수 있다")
  func exposesContextModel() {
    #expect(AttendanceType.present.desc == "PRESENT")
  }
}
