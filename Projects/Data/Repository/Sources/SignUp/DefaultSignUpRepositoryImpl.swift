//
//  DefaultSignUpRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

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

