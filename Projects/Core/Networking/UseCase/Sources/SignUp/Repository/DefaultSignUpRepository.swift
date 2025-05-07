//
//  DefaultSignUpRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//

import Model

final public class DefaultSignUpRepository: SignUpRepositoryProtocol {
  public init() {}
  
  public func validateInviteCode(
    code: String
  ) async throws -> InviteDTOModel? {
    return nil
  }
  
  public func signUpMember(member: Member) async throws -> MemberDTOSignUp? {
    return nil
  }
  
  public func signUpCoreMember(member: Member) async throws -> CoreMemberDTOSignUp? {
    return nil
  }
  
  public func registerAccount(
    userName: String,
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
}
