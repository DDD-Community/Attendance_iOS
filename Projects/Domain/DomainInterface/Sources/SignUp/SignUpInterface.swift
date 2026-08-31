//
//  SignUpInterface.swift
//  DomainInterface
//
//  Created by DDD on 7/23/25.
//

import Foundation

import Dependencies
import Entity

public protocol SignUpInterface: Sendable {
  func registerUser(
    input: SignUpUserInput
  ) async throws -> SignUpUser
}

/// SignUp Repository의 DependencyKey 구조체
public enum SignUpRepositoryDependency: TestDependencyKey {

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
