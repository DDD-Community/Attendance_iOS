//
//  DefaultProfileRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/8/25.
//

import Combine

import Model

public final class DefaultProfileRepository: ProfileRepositoryProtocol {
  
  public init() {}
  
  
  public func editProfileManger(
    name: String,
    inviteCode: String,
    role: String,
        team: String,
    responsibility: String
  ) async throws -> ProfileResponseModel? {
    return nil
  }
  
  public func editProfileMangerNoTeam(
    name: String,
    inviteCode: String,
    role: String,
    responsibility: String
  ) async throws -> ProfileResponseModel? {
    return nil
  }
  
  public func editProfileMember(
    name: String,
    inviteCode: String,
    role: String,
    team: String
  ) async throws -> ProfileResponseModel? {
    return nil
  }
  
  public func getProfile() async throws -> ProfileResponseModel? {
    return nil
  }
}

