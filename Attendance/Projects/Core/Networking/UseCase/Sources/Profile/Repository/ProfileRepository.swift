//
//  ProfileRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/8/25.
//

import Combine

import Model
import Service

import AsyncMoya

@Observable
public class ProfileRepository: ProfileRepositoryProtocol {
  
  public init(){}
  
  private let provider = MoyaProvider<ProfileService>(plugins: [MoyaLoggingPlugin()])
  
  public func editProfile(
    name: String,
    inviteCode: String,
    role: String,
    team: String
  ) async throws -> ProfiledDTO? {
    let profileModel = try await provider.requestAsync(.editProfile(
        username: name,
        inviteCodeId: inviteCode,
        role: role,
        team: team),decodeTo: ProfileModel.self)
    return profileModel.toProfileDTOModel()
  }
  
}
