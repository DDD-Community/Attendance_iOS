//
//  DefaultProfileRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface

final public class DefaultProfileRepositoryImpl: ProfileInterface {

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

