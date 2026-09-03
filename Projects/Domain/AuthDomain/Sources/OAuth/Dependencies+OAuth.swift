//
//  Dependencies+OAuth.swift
//  AuthDomain
//
//  Created by DDD on 12/29/25.
//

import Foundation
import Dependencies
import AuthDomainInterface

// MARK: - Apple OAuth Provider Registration

extension AppleOAuthProviderDependency: DependencyKey {
  /// 앱 실행 환경에서 Apple 로그인을 처리하는 실제 Provider를 제공한다.
  public static var liveValue: AppleOAuthProviderInterface {
    return AppleOAuthProvider()
  }
}

// MARK: - Google OAuth Provider Registration

extension GoogleOAuthProviderDependency: DependencyKey {
  /// 앱 실행 환경에서 Google 로그인을 처리하는 실제 Provider를 제공한다.
  public static var liveValue: GoogleOAuthProviderInterface {
    return GoogleOAuthProvider()
  }
}
