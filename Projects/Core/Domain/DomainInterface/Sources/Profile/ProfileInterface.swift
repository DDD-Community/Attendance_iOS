//
//  ProfileInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//

import Foundation

public protocol ProfileInterface {
  func editProfileManger(
    name: String,
    inviteCode: String,
    role: String,
    team: String,
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
    team: String
  ) async throws -> ProfileResponseModel?

  func getProfile() async throws -> ProfileResponseModel?
}
