//
//  DependencyValues+Auth.swift
//  FeatureAssembly
//
//  Auth·OAuth 구현 등록.
//  인터페이스(TestDependencyKey)에 실제 구현(liveValue)을 붙이는 조립 지점.
//

import Dependencies
import DomainInterface

import Repository
import UseCase

extension AuthRepositoryDependency: DependencyKey {
  public static var liveValue: AuthInterface { AuthRepositoryImpl() }
}

extension GoogleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue: GoogleOAuthInterface { GoogleOAuthRepositoryImpl() }
}

extension AppleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue: AppleOAuthInterface { AppleOAuthRepositoryImpl() }
}

extension AppleAuthRequestDependency: DependencyKey {
  public static var liveValue: AppleAuthRequestInterface { AppleLoginRepositoryImpl() }
}

extension AppleOAuthProviderDependency: DependencyKey {
  public static var liveValue: AppleOAuthProviderInterface { AppleOAuthProvider() }
}

extension GoogleOAuthProviderDependency: DependencyKey {
  public static var liveValue: GoogleOAuthProviderInterface { GoogleOAuthProvider() }
}
