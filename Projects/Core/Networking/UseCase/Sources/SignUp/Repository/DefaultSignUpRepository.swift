//
//  DefaultSignUpRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//

import Model

final public class DefaultSignUpRepository: SignUpRepositoryProtocol {
  public init() {}
  
  public func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpDTOModel? {
    return nil
  }
  
  public func validateInviteCode(
    inviteCode: String
  ) async throws -> SignUPInviteDTOModel? {
    return nil
  }
  
  public func checkEmail(email: String) async throws -> CheckEmailDTO? {
    return nil
  }
}
