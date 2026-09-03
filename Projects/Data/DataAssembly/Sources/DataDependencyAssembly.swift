//
//  DataDependencyAssembly.swift
//  DataAssembly
//

import Dependencies
import DomainInterface
import ServiceAssembly

/// Data 계층의 live `DependencyKey` conformance와 하위 Service 조립을 유지합니다.
public struct DataDependencyAssemblyToken {
  fileprivate let dependencyKeys: [any DependencyKey.Type]
  fileprivate let serviceAssembly: ServiceDependencyAssemblyToken
}

public enum DataDependencyAssembly {
  public static func bootstrap() -> DataDependencyAssemblyToken {
    DataDependencyAssemblyToken(
      dependencyKeys: [
        AttendanceRepositoryDependency.self,
        ScheduleRepositoryDependency.self,
        QRCodeRepositoryDependency.self,
        AuthRepositoryDependency.self,
        GoogleOAuthRepositoryDependencyKey.self,
        AppleOAuthRepositoryDependencyKey.self,
        AppleAuthRequestDependency.self,
        OnBoardingRepositoryDependency.self,
        SignUpRepositoryDependency.self,
        ProfileRepositoryDependency.self,
        MyPageRepositoryDependency.self,
        AppUpdateRepositoryDependency.self,
        VoteRepositoryDependency.self
      ],
      serviceAssembly: ServiceDependencyAssembly.bootstrap()
    )
  }
}
