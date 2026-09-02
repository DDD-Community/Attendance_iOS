//
//  FeatureAssemblyTests.swift
//  FeatureAssemblyTests
//
//  Created by DDD on 2026-09-02
//

import Testing

@testable import FeatureAssembly

@Suite("FeatureAssembly")
struct FeatureAssemblyTests {
  @Test("FeatureAssembly는 Auth feature 타입을 재수출한다")
  func reexportsAuthFeature() {
    let reducer = Login()

    #expect(String(describing: type(of: reducer)) == "Login")
  }

  @Test("FeatureAssembly는 Splash feature 타입을 재수출한다")
  func reexportsSplashFeature() {
    let reducer = Splash()

    #expect(String(describing: type(of: reducer)) == "Splash")
  }
}
