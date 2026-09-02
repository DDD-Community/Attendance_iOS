//
//  RepositoryFactory.swift
//  FeatureAssembly
//
//  Created by DDD on 9/2/26.
//

import DomainInterface
import Repository

/// FeatureAssembly에서 Domain 인터페이스와 Data 구현을 연결하는 Repository 팩토리입니다.
enum RepositoryFactory {
  static var attendance: any AttendanceInterface {
    return AttendanceRepositoryImpl()
  }

  static var schedule: any ScheduleInterface {
    return ScheduleRepositoryImpl()
  }

  static var qrCode: any QRCodeInterface {
    return QRCodeRepositoryImpl()
  }

  static var auth: any AuthInterface {
    return AuthRepositoryImpl()
  }

  static var onBoarding: any OnBoardingInterface {
    return OnBoardingRepositoryImpl()
  }

  static var signUp: any SignUpInterface {
    return SignUpRepositoryImpl()
  }

  static var profile: any ProfileInterface {
    return ProfileRepositoryImpl()
  }

  static var myPage: any MyPageRepositoryInterface {
    return MyPageRepositoryImpl()
  }

  static var vote: any VoteInterface {
    return VoteRepositoryImpl()
  }

  static var googleOAuth: any GoogleOAuthInterface {
    return GoogleOAuthRepositoryImpl()
  }

  static var appleOAuth: any AppleOAuthInterface {
    return AppleOAuthRepositoryImpl()
  }

  static var appleAuthRequest: any AppleAuthRequestInterface {
    return AppleLoginRepositoryImpl()
  }

  static var appUpdate: any AppUpdateInterface {
    return AppUpdateRepositoryImpl()
  }
}
