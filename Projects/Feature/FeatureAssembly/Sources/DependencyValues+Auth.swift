//
//  DependencyValues+Auth.swift
//  FeatureAssembly
//
//  Created by DDD on 9/2/26.
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
