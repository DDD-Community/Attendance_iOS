//
//  FeatureDependencyAssembly.swift
//  FeatureAssembly
//

import DataAssembly
import DomainAssembly

/// 앱이 직접 참조하는 유일한 live dependency 조립 진입점입니다.
public struct FeatureDependencyAssemblyToken {
  fileprivate let dataAssembly: DataDependencyAssemblyToken
  fileprivate let domainAssembly: DomainDependencyAssemblyToken
}

public enum FeatureDependencyAssembly {
  public static func bootstrap() -> FeatureDependencyAssemblyToken {
    FeatureDependencyAssemblyToken(
      dataAssembly: DataDependencyAssembly.bootstrap(),
      domainAssembly: DomainDependencyAssembly.bootstrap()
    )
  }
}
