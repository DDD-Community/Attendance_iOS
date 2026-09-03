//
//  AppDependencyRegistration.swift
//  FeatureAssembly
//

import Dependencies
import DomainAssembly

public extension DependencyValues {
  /// 앱 Store가 사용할 live 구현을 현재 dependency scope에 조립합니다.
  mutating func registerAppDependencies() {
    DomainDependencyAssembly.register(into: &self)
  }
}
