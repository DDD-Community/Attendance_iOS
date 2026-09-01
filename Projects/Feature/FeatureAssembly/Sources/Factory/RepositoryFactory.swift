//
//  RepositoryFactory.swift
//  FeatureAssembly
//
//  Created by DDD on 9/1/26.
//

import DDDNetworkInterface
import DomainInterface
import Repository
import ServiceAssembly

enum RepositoryFactory {
  static var attendance: any AttendanceInterface {
    return AttendanceRepositoryImpl(client: networkClient)
  }

  static var schedule: any ScheduleInterface {
    return ScheduleRepositoryImpl(client: networkClient)
  }

  static var qrCode: any QRCodeInterface {
    return QRCodeRepositoryImpl(client: networkClient)
  }

  static var auth: any AuthInterface {
    return AuthRepositoryImpl(
      client: networkClient,
      authService: NetworkContainer.authService
    )
  }

  static var onBoarding: any OnBoardingInterface {
    return OnBoardingRepositoryImpl(client: networkClient)
  }

  static var signUp: any SignUpInterface {
    return SignUpRepositoryImpl(client: networkClient)
  }

  static var profile: any ProfileInterface {
    return ProfileRepositoryImpl(client: networkClient)
  }

  static var myPage: any MyPageRepositoryInterface {
    return MyPageRepositoryImpl(client: networkClient)
  }

  static var vote: any VoteInterface {
    return VoteRepositoryImpl(client: networkClient)
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

private extension RepositoryFactory {
  static var networkClient: any DDDNetworkClient {
    return NetworkContainer.authenticatedClient
  }
}
