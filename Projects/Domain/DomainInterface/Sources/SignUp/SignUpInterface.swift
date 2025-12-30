//
//  SignUpInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Updated for WeaveDI v4.0 - Protocol-based DI Registration
//

import Foundation
import WeaveDI

public protocol SignUpInterface: Sendable {
  func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpModel?
  func validateInviteCode(inviteCode: String) async throws -> InviteCodeModel?
  func checkEmail(email: String)  async throws -> CheckEmailModel?
}

/// SignUp Repository의 DependencyKey 구조체
public struct SignUpRepositoryDependency: DependencyKey {
  public static var liveValue: SignUpInterface {
    UnifiedDI.resolve(SignUpInterface.self) ?? DefaultSignUpRepositoryImpl()
  }

  public static var testValue: SignUpInterface {
    DefaultSignUpRepositoryImpl.success()
  }

  public static var previewValue: SignUpInterface {
    DefaultSignUpRepositoryImpl.success()
  }
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var signUpRepository: SignUpInterface {
    get { self[SignUpRepositoryDependency.self] }
    set { self[SignUpRepositoryDependency.self] = newValue }
  }
}
