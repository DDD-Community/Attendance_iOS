//
//  DependencyValues+Core.swift
//  FeatureAssembly
//
//  키체인·토큰 등 인프라 구현 등록.
//  인터페이스(TestDependencyKey)에 실제 구현(liveValue)을 붙이는 조립 지점.
//

import Dependencies
import DomainInterface
import ServiceAssembly

extension KeychainManagerDependency: DependencyKey {
  public static var liveValue: KeychainManaging {
    return NetworkContainer.keychainManager
  }
}
