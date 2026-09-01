//
//  OAuthDependencyRegistrationTests.swift
//  UseCaseTests
//
//  Created by DDD on 9/1/26.
//

import Dependencies
import DomainInterface
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
}
