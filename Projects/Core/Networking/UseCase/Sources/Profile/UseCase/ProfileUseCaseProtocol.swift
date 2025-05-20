//
//  ProfileUseCaseProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

import Model

public protocol ProfileUseCaseProtocol {
  func editProfileManger(
    name: String,
    inviteCode: String,
    role: String,
    crew: String,
    responsibility: String
  ) async throws -> ProfileDTOModel?
  
  func editProfileMangerNoTeam(
    name: String,
    inviteCode: String,
    role: String,
    responsibility: String
  ) async throws -> ProfileDTOModel?
  
  func editProfileMember(
    name: String,
    inviteCode: String,
    role: String,
    crew: String
  ) async throws -> ProfileDTOModel?
  
  func getProfile() async throws -> ProfileDTOModel?
}
