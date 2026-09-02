//
//  DataAssemblyTests.swift
//  DataAssemblyTests
//
//  Created by DDD on 9/2/26.
//

import Testing

@testable import DataAssembly

@Suite("DataAssembly")
struct DataAssemblyTests {
  @Test("Model의 public API를 DataAssembly에서 재수출한다")
  func reexportsModel() {
    #expect(AttendanceType.present.desc == "PRESENT")
  }
}
