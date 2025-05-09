//
//  SignUpRepositoryProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//

import Foundation

import Model

public protocol SignUpRepositoryProtocol {
  func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpDTOModel?
  func validateInviteCode(inviteCode: String) async throws -> SignUPInviteDTOModel?
  func checkEmail(email: String)  async throws -> CheckEmailDTO?
}
