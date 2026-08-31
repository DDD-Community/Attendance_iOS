//
//  AppleAuthRequestInterface.swift
//  DomainInterface
//
//  Created by DDD on 12/26/25.
//

import Foundation

import Dependencies
import AuthenticationServices

public protocol AppleAuthRequestInterface: Sendable {
  func prepare(_ request: ASAuthorizationAppleIDRequest) -> String
}

///// OAuth Repository의 DependencyKey 구조체
public struct  AppleAuthRequestDependency: DependencyKey {

  public static var testValue: AppleAuthRequestInterface {
    DefaultAppleAuthRequestImpl()
  }

  public static var previewValue: AppleAuthRequestInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var appleManger: AppleAuthRequestInterface {
    get { self[AppleAuthRequestDependency.self] }
    set { self[AppleAuthRequestDependency.self] = newValue }
  }
}

