//
//  DependencyValues+Provider.swift
//  UseCase
//
//  UseCase 모듈이 소유한 구현(OAuth Provider·Keychain)의 등록부.
//  DomainInterface 의 TestDependencyKey 에 liveValue 를 붙인다.
//

import Dependencies
import DomainInterface

// MARK: - OAuth Provider

extension AppleOAuthProviderDependency: DependencyKey {
  public static var liveValue: AppleOAuthProviderInterface { AppleOAuthProvider() }
}

extension GoogleOAuthProviderDependency: DependencyKey {
  public static var liveValue: GoogleOAuthProviderInterface { GoogleOAuthProvider() }
}

// MARK: - Keychain

extension KeychainManagerDependency: DependencyKey {
  public static var liveValue: KeychainManaging { KeychainManager() }
}
