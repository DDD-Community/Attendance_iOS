//
//  DependencyValues+Auth.swift
//  FeatureAssembly
//
//  Auth·OAuth 구현 등록.
//  인터페이스(TestDependencyKey)에 실제 구현(liveValue)을 붙이는 조립 지점.
//

import Dependencies
import DomainInterface

extension AuthRepositoryDependency: DependencyKey {
  public static var liveValue: AuthInterface {
    return RepositoryFactory.auth
  }
}

extension GoogleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue: GoogleOAuthInterface {
    return RepositoryFactory.googleOAuth
  }
}

extension AppleOAuthRepositoryDependencyKey: DependencyKey {
  public static var liveValue: AppleOAuthInterface {
    return RepositoryFactory.appleOAuth
  }
}

extension AppleAuthRequestDependency: DependencyKey {
  public static var liveValue: AppleAuthRequestInterface {
    return RepositoryFactory.appleAuthRequest
  }
}
