//
//  AuthInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Updated for WeaveDI v4.0 - Protocol-based DI Registration
//

import Foundation
import WeaveDI
import Dependencies
import Entity

/// Auth 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol AuthInterface: Sendable {
  func login(provider: SocialType, token: String) async throws -> LoginEntity
  func refresh()  async throws -> AuthTokens
  func withDraw(token: String) async throws -> WithdrawEntity
  func logout() async throws -> AuthExitEntity
  func updateSessionCredential(with tokens: AuthTokens)
}

/// Auth Repository의 DependencyKey 구조체
public struct AuthRepositoryDependency: DependencyKey {
  public static var liveValue: AuthInterface {
    UnifiedDI.resolve(AuthInterface.self) ??  DefaultAuthRepositoryImpl()
  }

  public static var testValue: AuthInterface {
    UnifiedDI.resolve(AuthInterface.self) ??  DefaultAuthRepositoryImpl()
  }

  public static var previewValue: AuthInterface = liveValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var authRepository: AuthInterface {
    get { self[AuthRepositoryDependency.self] }
    set { self[AuthRepositoryDependency.self] = newValue }
  }
}
