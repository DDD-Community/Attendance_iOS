//
//  DefaultSignUpRepositoryImpl.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Moved from Repository module
//

import Foundation
import Model

/// SignUp Repository의 기본 구현체 (테스트/프리뷰용)
final public class DefaultSignUpRepositoryImpl: SignUpInterface {
  public init() {}

  public func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpModel? {
    return nil
  }

  public func validateInviteCode(
    inviteCode: String
  ) async throws -> InviteCodeModel? {
    return nil
  }

  public func checkEmail(email: String) async throws -> CheckEmailModel? {
    return nil
  }
}