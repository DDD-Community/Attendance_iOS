//
//  ProfileRepositoryProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/8/25.
//

import Foundation

import Model

public protocol ProfileRepositoryProtocol {
  func editProfileManger(
    name: String,
    inviteCode: String,
    role: String,
    crew: String,
    responsibility: String
  ) async throws -> ProfileResponseModel?
  
  func editProfileMangerNoTeam(
    name: String,
    inviteCode: String,
    role: String,
    responsibility: String
  ) async throws -> ProfileResponseModel?
  
  func editProfileMember(
    name: String,
    inviteCode: String,
    role: String,
    crew: String
  ) async throws -> ProfileResponseModel?
  
  func getProfile() async throws -> ProfileResponseModel?
}
