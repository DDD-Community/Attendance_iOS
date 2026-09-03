//
//  RepositoryDependencyModules.swift
//  Repository
//

import Dependencies
import DomainInterface

public extension DependencyValues {
  /// 출석 도메인의 Data 구현을 등록합니다.
  mutating func registerAttendanceRepositories() {
    attendanceRepository = resolve { AttendanceRepositoryImpl() }
    scheduleRepository = resolve { ScheduleRepositoryImpl() }
    qrCodeRepository = resolve { QRCodeRepositoryImpl() }
  }

  /// 인증 도메인의 Data 구현을 등록합니다.
  mutating func registerAuthRepositories() {
    authRepository = resolve { AuthRepositoryImpl() }
    googleOAuthRepository = resolve { GoogleOAuthRepositoryImpl() }
    appleManger = resolve { AppleLoginRepositoryImpl() }
    appleOAuthRepository = resolve { AppleOAuthRepositoryImpl() }
  }

  /// 온보딩 도메인의 Data 구현을 등록합니다.
  mutating func registerOnBoardingRepositories() {
    onBoardingRepository = resolve { OnBoardingRepositoryImpl() }
    signUpRepository = resolve { SignUpRepositoryImpl() }
  }

  /// 프로필 도메인의 Data 구현을 등록합니다.
  mutating func registerProfileRepositories() {
    profileRepository = resolve { ProfileRepositoryImpl() }
    myPageRepository = resolve { MyPageRepositoryImpl() }
    appUpdateRepository = resolve { AppUpdateRepositoryImpl() }
  }

  /// 투표 도메인의 Data 구현을 등록합니다.
  mutating func registerVoteRepositories() {
    voteRepository = resolve { VoteRepositoryImpl() }
  }

  /// 앞에서 등록된 하위 의존성을 `@Dependency` 생성 시점에도 전달합니다.
  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies {
      $0 = self
    } operation: {
      makeValue()
    }
  }
}
