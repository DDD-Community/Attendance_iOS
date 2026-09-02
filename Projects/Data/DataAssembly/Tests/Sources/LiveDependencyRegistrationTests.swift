//
//  LiveDependencyRegistrationTests.swift
//  DataAssemblyTests
//
//  Created by DDD on 9/2/26.
//

import Dependencies
import DomainInterface
import Testing

@testable import DataAssembly

@Suite("DataAssembly 라이브 의존성")
struct LiveDependencyRegistrationTests {
  @Test("모든 Repository와 인증 인프라가 live context에서 등록된다")
  func resolvesAllLiveDependencies() {
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
      @Dependency(\.keychainManager) var keychainManager

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
      _ = keychainManager
    }
  }
}
