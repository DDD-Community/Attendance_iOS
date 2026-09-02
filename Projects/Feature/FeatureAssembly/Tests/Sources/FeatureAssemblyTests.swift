//
//  FeatureAssemblyTests.swift
//  FeatureAssemblyTests
//
//  Created by DDD on 2026-09-02
//

import Dependencies
import DomainInterface
import Testing

@testable import FeatureAssembly

@Suite("FeatureAssembly")
struct FeatureAssemblyTests {
  @Test("FeatureAssembly는 Auth feature 타입을 재수출한다")
  func reexportsAuthFeature() {
    let reducer = Login()

    #expect(String(describing: type(of: reducer)) == "Login")
  }

  @Test("FeatureAssembly는 Splash feature 타입을 재수출한다")
  func reexportsSplashFeature() {
    let reducer = Splash()

    #expect(String(describing: type(of: reducer)) == "Splash")
  }

  @Test("Repository 라이브 구현은 FeatureAssembly에서 해결된다")
  func resolvesRepositoryLiveDependencies() {
    withDependencies {
      $0.context = .live
    } operation: {
      @Dependency(\.attendanceRepository) var attendanceRepository
      @Dependency(\.scheduleRepository) var scheduleRepository
      @Dependency(\.qrCodeRepository) var qrCodeRepository
      @Dependency(\.authRepository) var authRepository
      @Dependency(\.googleOAuthRepository) var googleOAuthRepository
      @Dependency(\.appleOAuthRepository) var appleOAuthRepository
      @Dependency(\.appleManger) var appleAuthRequest
      @Dependency(\.onBoardingRepository) var onBoardingRepository
      @Dependency(\.signUpRepository) var signUpRepository
      @Dependency(\.profileRepository) var profileRepository
      @Dependency(\.myPageRepository) var myPageRepository
      @Dependency(\.appUpdateRepository) var appUpdateRepository
      @Dependency(\.voteRepository) var voteRepository

      _ = attendanceRepository
      _ = scheduleRepository
      _ = qrCodeRepository
      _ = authRepository
      _ = googleOAuthRepository
      _ = appleOAuthRepository
      _ = appleAuthRequest
      _ = onBoardingRepository
      _ = signUpRepository
      _ = profileRepository
      _ = myPageRepository
      _ = appUpdateRepository
      _ = voteRepository
    }
  }
}
