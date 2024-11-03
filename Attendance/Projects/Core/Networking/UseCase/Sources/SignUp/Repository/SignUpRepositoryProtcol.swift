//
//  SignUpRepositoryProtcol.swift
//  UseCase
//
//  Created by Wonji Suh  on 11/3/24.
//


import Foundation
import Model

public protocol SignUpRepositoryProtcol {
  func validateInviteCode(code: String) async throws -> InviteDTOModel?
}
