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
  ) async throws -> SignUpModel?
  func validateInviteCode(inviteCode: String) async throws -> InviteCodeModel?
  func checkEmail(email: String)  async throws -> CheckEmailModel?
}
