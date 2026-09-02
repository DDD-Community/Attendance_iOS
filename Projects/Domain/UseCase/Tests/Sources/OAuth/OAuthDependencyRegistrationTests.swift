//
//  OAuthDependencyRegistrationTests.swift
//  UseCaseTests
//
//  Created by DDD on 9/1/26.
//

import Dependencies
import DomainInterface
import Entity
import Sharing
import Testing
@testable import UseCase

@Suite("OAuth 라이브 의존성 등록")
struct OAuthDependencyRegistrationTests {
  @Test("Apple OAuth Provider가 라이브 구현으로 해석된다")
  func appleProviderResolvesFromLiveContext() {
    withDependencies {
      $0 = .live
    } operation: {
      @Dependency(\.appleOAuthProvider) var provider

      #expect(provider is AppleOAuthProvider)
    }
  }

  @Test("Google OAuth Provider가 라이브 구현으로 해석된다")
  func googleProviderResolvesFromLiveContext() {
    withDependencies {
      $0 = .live
    } operation: {
      @Dependency(\.googleOAuthProvider) var provider

      #expect(provider is GoogleOAuthProvider)
    }
  }

  @Test("Google 로그인 결과가 프로필 API 역할 선택값을 갱신한다")
  @MainActor
  func googleLoginSynchronizesPersistedRole() async throws {
    @Shared(.appStorage("staffRole")) var staffRole: Staff?
    $staffRole.withLock { $0 = .manager }
    defer { $staffRole.withLock { $0 = nil } }

    let authRepository = MockAuthRepository()
    authRepository.configureSuccessfulLogin(provider: .google, role: .member)

    let useCase = withDependencies {
      $0.authRepository = authRepository
      $0.googleOAuthProvider = MockGoogleOAuthProvider()
    } operation: {
      UnifiedOAuthUseCase()
    }

    _ = try await useCase.googleLogin(token: "google-token")

    #expect(staffRole == .member)
  }

  @Test("신규 사용자는 이전 계정의 프로필 API 역할 선택값을 제거한다")
  @MainActor
  func newGoogleUserClearsPersistedRole() async throws {
    @Shared(.appStorage("staffRole")) var staffRole: Staff?
    $staffRole.withLock { $0 = .manager }
    defer { $staffRole.withLock { $0 = nil } }

    let authRepository = MockAuthRepository()
    authRepository.configureSuccessfulLogin(isNewUser: true, provider: .google, role: nil)

    let useCase = withDependencies {
      $0.authRepository = authRepository
      $0.googleOAuthProvider = MockGoogleOAuthProvider()
    } operation: {
      UnifiedOAuthUseCase()
    }

    _ = try await useCase.googleLogin(token: "google-token")

    #expect(staffRole == nil)
  }
}
