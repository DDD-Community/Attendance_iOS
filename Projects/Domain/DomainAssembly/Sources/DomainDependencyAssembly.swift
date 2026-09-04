//
//  DomainDependencyAssembly.swift
//  DomainAssembly
//

import Dependencies
import AppUpdateDomain
import AttendanceDomain
import AuthDomain
import DDDStorageInterface
import MyPageDomain
import OnBoardingDomain
import ProfileDomain
import QRCodeDomain
import ScheduleDomain
import ServiceAssembly
import VoteDomain

public enum DomainDependencyAssembly {
  public static func register(into values: inout DependencyValues) {
    ServiceDependencyAssembly.register(into: &values)
    values.sessionCacheInvalidator = LocalSessionCacheInvalidator(
      profile: values.profileLocalDataSource,
      schedule: values.scheduleLocalDataSource
    )
    values.registerAppUpdateRepository()
    values.registerAttendanceRepository()
    values.registerAuthRepositories()
    values.registerMyPageRepository()
    values.registerOnBoardingRepositories()
    values.registerProfileRepository()
    values.registerQRCodeRepository()
    values.registerScheduleRepository()
    values.registerVoteRepository()

    values.attendanceUseCase = resolve(in: values) { AttendanceUseCaseImpl() }
    values.scheduleUseCase = resolve(in: values) { ScheduleUseCaseImpl() }
    values.qrCodeUseCase = resolve(in: values) { QRCodeUseCaseImpl() }
    values.authUseCase = resolve(in: values) { AuthUseCaseImpl() }
    values.appleOAuthProvider = resolve(in: values) { AppleOAuthProvider() }
    values.googleOAuthProvider = resolve(in: values) { GoogleOAuthProvider() }
    values.unifiedOAuthUseCase = resolve(in: values) { UnifiedOAuthUseCase() }
    values.profileUseCase = resolve(in: values) { ProfileUseCaseImpl() }
    values.appUpdateUseCase = resolve(in: values) { AppUpdateUseCaseImpl() }
    values.myPageUseCase = MyPageUseCaseImpl(repository: values.myPageRepository)
    values.onBoardingUseCase = resolve(in: values) { OnBoardingUseCaseImpl() }
    values.signUpUseCase = resolve(in: values) { SignUpUseCaseImpl() }
    values.voteUseCase = resolve(in: values) { VoteUseCaseImpl() }
  }

  private static func resolve<Value>(
    in values: DependencyValues,
    _ makeValue: () -> Value
  ) -> Value {
    withDependencies {
      $0 = values
    } operation: {
      makeValue()
    }
  }
}

private struct LocalSessionCacheInvalidator: SessionCacheInvalidating {
  let profile: any ProfileLocalDataSourceProtocol
  let schedule: any ScheduleLocalDataSourceProtocol

  func invalidate() async {
    try? await profile.clear()
    try? await schedule.clear()
  }
}
