//
//  DomainDependencyAssembly.swift
//  DomainAssembly
//

import UseCase

/// Domain 조립 모듈의 하위 UseCase 등록을 유지하는 토큰입니다.
public struct DomainDependencyAssemblyToken {
  fileprivate let useCaseAssembly: UseCaseDependencyAssemblyToken
}

public enum DomainDependencyAssembly {
  public static func bootstrap() -> DomainDependencyAssemblyToken {
    DomainDependencyAssemblyToken(
      useCaseAssembly: UseCaseDependencyAssembly.bootstrap()
    )
  }
}
