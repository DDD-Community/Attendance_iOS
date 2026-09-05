//
//  DomainDependencyAssembly.swift
//  DomainAssembly
//

import Dependencies
import DDDStorageInterface
import ProfileDomain
import ScheduleDomain
import ServiceAssembly

public enum DomainDependencyAssembly {
  /// Domain 모듈의 Repository/UseCase는 각 모듈이 `liveValue`로 직접 등록한다.
  /// 여기서는 한 모듈이 소유할 수 없는 조립만 담당한다.
  public static func register(into values: inout DependencyValues) {
    ServiceDependencyAssembly.register(into: &values)

    // Profile/Schedule 두 모듈에 걸쳐 있어 조립 경계에서만 만들 수 있다.
    values.sessionCacheInvalidator = LocalSessionCacheInvalidator()
  }
}

private struct LocalSessionCacheInvalidator: SessionCacheInvalidating {
  @Dependency(\.profileLocalDataSource) private var profile
  @Dependency(\.scheduleLocalDataSource) private var schedule

  func invalidate() async {
    try? await profile.clear()
    try? await schedule.clear()
  }
}
