//
//  DependencyValues+Repository.swift
//  Repository
//
//  Repository 구현 등록부.
//  DomainInterface 는 `TestDependencyKey`(testValue = Default/Mock)만 선언하고,
//  실제 구현(liveValue)은 구현 모듈인 여기서 붙인다.
//  — swift-dependencies 의 "Separating interface and implementation" 패턴.
//    App 이 중앙에서 등록하던 방식(WeaveDI DiRegister)을 모듈이 자기 구현을 등록하는 방식으로 바꿨다.
//

import Dependencies
import DomainInterface
import Foundations

// MARK: - Auth

extension AuthRepositoryDependency: DependencyKey {
  public static var liveValue: AuthInterface { AuthRepositoryImpl() }
}

// MARK: - OAuth

extension GoogleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue: GoogleOAuthInterface { GoogleOAuthRepositoryImpl() }
}

extension AppleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue: AppleOAuthInterface { AppleOAuthRepositoryImpl() }
}

extension AppleAuthRequestDependency: DependencyKey {
  public static var liveValue: AppleAuthRequestInterface { AppleLoginRepositoryImpl() }
}

// MARK: - OnBoarding / SignUp

extension OnBoardingRepositoryDependency: DependencyKey {
  public static var liveValue: OnBoardingInterface { OnBoardingRepositoryImpl() }
}

extension SignUpRepositoryDependency: DependencyKey {
  public static var liveValue: SignUpInterface { SignUpRepositoryImpl() }
}

// MARK: - Attendance / Schedule / QRCode / Vote

extension AttendanceRepositoryDependency: DependencyKey {
  public static var liveValue: AttendanceInterface { AttendanceRepositoryImpl() }
}

extension ScheduleRepositoryDependency: DependencyKey {
  public static var liveValue: ScheduleInterface { ScheduleRepositoryImpl() }
}

extension QRCodeRepositoryDependency: DependencyKey {
  public static var liveValue: QRCodeInterface { QRCodeRepositoryImpl() }
}

extension VoteRepositoryDependency: DependencyKey {
  public static var liveValue: VoteInterface { VoteRepositoryImpl() }
}

// MARK: - Profile / MyPage / AppUpdate

extension ProfileRepositoryDependency: DependencyKey {
  public static var liveValue: ProfileInterface { ProfileRepositoryImpl() }
}

extension MyPageRepositoryDependency: DependencyKey {
  public static var liveValue: any MyPageRepositoryInterface { MyPageRepositoryImpl() }
}

extension AppUpdateRepositoryDependency: DependencyKey {
  public static var liveValue: AppUpdateInterface { AppUpdateRepositoryImpl() }
}

// MARK: - Token

extension TokenProviderKey: DependencyKey {
  public static var liveValue: TokenProviding { KeychainTokenProvider() }
}
