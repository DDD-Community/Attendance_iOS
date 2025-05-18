//
//  ProfileUseCaseProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

import Model

public protocol ProfileUseCaseProtocol {
  func editProfile(
    name: String,
    inviteCode: String,
    role: String,
    crew: String,
    responsibility: String
  ) async throws -> ProfileDTOModel?
  func getProfile() async throws -> ProfileDTOModel?
}
