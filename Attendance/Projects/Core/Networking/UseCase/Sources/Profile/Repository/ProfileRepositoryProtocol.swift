//
//  ProfileRepositoryProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

import Model

public protocol ProfileRepositoryProtocol {
  func editProfile(
    name: String,
    inviteCode: String,
    role: String,
    team: String
  ) async throws -> ProfileDTOModel?
  func getProfile() async throws -> ProfileDTOModel?
}
