//
//  ServiceDependencyAssembly.swift
//  ServiceAssembly
//

import DDDAuthInterface
import DDDNetworkInterface
import Dependencies
import DomainInterface

/// Service 계층의 live `DependencyKey` conformance를 정적 링크에 유지하는 토큰입니다.
public struct ServiceDependencyAssemblyToken {
  fileprivate let dependencyKeys: [any DependencyKey.Type]
}

public enum ServiceDependencyAssembly {
  /// live 값을 생성하지 않고 conformance witness만 명시적으로 참조합니다.
  public static func bootstrap() -> ServiceDependencyAssemblyToken {
    ServiceDependencyAssemblyToken(
      dependencyKeys: [
        KeychainManagerDependency.self,
        NetworkClientDependency.self,
        AuthServiceDependency.self
      ]
    )
  }
}
