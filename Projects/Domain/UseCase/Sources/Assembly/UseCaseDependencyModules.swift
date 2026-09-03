//
//  UseCaseDependencyModules.swift
//  UseCase
//

import Dependencies
import DomainInterface

public extension DependencyValues {
  /// 출석 도메인의 UseCase 구현을 등록합니다.
  mutating func registerAttendanceUseCases() {
    attendanceUseCase = resolve { AttendanceUseCaseImpl() }
    scheduleUseCase = resolve { ScheduleUseCaseImpl() }
    qrCodeUseCase = resolve { QRCodeUseCaseImpl() }
  }

  /// 인증 도메인의 UseCase와 OAuth Provider를 등록합니다.
  mutating func registerAuthUseCases() {
    authUseCase = resolve { AuthUseCaseImpl() }
    appleOAuthProvider = resolve { AppleOAuthProvider() }
    googleOAuthProvider = resolve { GoogleOAuthProvider() }
    unifiedOAuthUseCase = resolve { UnifiedOAuthUseCase() }
  }

  /// 프로필 도메인의 UseCase 구현을 등록합니다.
  mutating func registerProfileUseCases() {
    profileUseCase = resolve { ProfileUseCaseImpl() }
    appUpdateUseCase = resolve { AppUpdateUseCaseImpl() }
    myPageUseCase = MyPageUseCaseImpl(repository: myPageRepository)
  }

  /// 온보딩 도메인의 UseCase 구현을 등록합니다.
  mutating func registerOnBoardingUseCases() {
    onBoardingUseCase = resolve { OnBoardingUseCaseImpl() }
    signUpUseCase = resolve { SignUpUseCaseImpl() }
  }

  /// 투표 도메인의 UseCase 구현을 등록합니다.
  mutating func registerVoteUseCases() {
    voteUseCase = resolve { VoteUseCaseImpl() }
  }

  /// 앞에서 등록된 Repository와 Provider를 `@Dependency` 생성 시점에 전달합니다.
  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies {
      $0 = self
    } operation: {
      makeValue()
    }
  }
}
