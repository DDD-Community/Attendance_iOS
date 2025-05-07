//
//  SignUpUseCaseProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import Model

public protocol SignUpUseCaseProtocol {
  func validateInviteCode(code: String) async throws -> InviteDTOModel?
  func signUpMember(member: Member) async throws -> MemberDTOSignUp?
  func signUpCoreMember(member: Member) async throws -> CoreMemberDTOSignUp?
  func registerAccount(userName: String, email: String,  password: String) async throws -> SignUpDTOModel?
  func validateInviteCode(inviteCode: String) async throws -> SignUPInviteDTOModel?
}
