//
//  SignUpInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//

import Foundation

public protocol SignUpInterface {
  func registerAccount(
    email: String,
    password: String
  ) async throws -> SignUpModel?
  func validateInviteCode(inviteCode: String) async throws -> InviteCodeModel?
  func checkEmail(email: String)  async throws -> CheckEmailModel?
}
