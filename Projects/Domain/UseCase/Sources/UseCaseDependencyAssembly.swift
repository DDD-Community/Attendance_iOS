//
//  UseCaseDependencyAssembly.swift
//  UseCase
//

import Dependencies
import DomainInterface

/// UseCase 계층에서 제공하는 모든 live `DependencyKey`를 정적 링크에 유지합니다.
public struct UseCaseDependencyAssemblyToken {
  fileprivate let dependencyKeys: [any DependencyKey.Type]
}

public enum UseCaseDependencyAssembly {
  public static func bootstrap() -> UseCaseDependencyAssemblyToken {
    UseCaseDependencyAssemblyToken(
      dependencyKeys: [
        AppUpdateUseCaseImpl.self,
        AttendanceUseCaseImpl.self,
        AuthUseCaseImpl.self,
        FetchAttendancesUseCaseKey.self,
        FetchMySchedulesUseCaseKey.self,
        AppleOAuthProviderDependency.self,
        GoogleOAuthProviderDependency.self,
        UnifiedOAuthUseCase.self,
        OnBoardingUseCaseImpl.self,
        ProfileUseCaseImpl.self,
        QRCodeUseCaseImpl.self,
        ScheduleUseCaseImpl.self,
        SignUpUseCaseImpl.self,
        VoteUseCaseImpl.self
      ]
    )
  }
}
