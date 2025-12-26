//
//  DefaultAuthRepositoryImpl.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Moved from Repository module
//

import Foundation
import Model

/// Auth Repository의 기본 구현체 (테스트/프리뷰용)
final public class DefaultAuthRepositoryImpl: AuthInterface {

  public init() {}

  public func loginUser(
    email: String
  ) async throws -> LoginModel? {
    return nil
  }
}