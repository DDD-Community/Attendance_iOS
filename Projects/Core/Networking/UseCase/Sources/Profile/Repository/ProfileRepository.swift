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
  
  // MARK: - 프로필 수정
  public func editProfile(
    name: String,
    inviteCode: String,
    role: String,
    crew: String,
    responsibility: String
  ) async throws -> ProfileDTOModel? {
    let profileModel = try await provider.requestAsync(.editProfile(
        username: name,
        inviteCodeId: inviteCode,
        role: role,
        crew: crew,
        responsibility:  responsibility),decodeTo: ProfileModel.self)
    return profileModel.toProfileDTOModel()
  }
  
  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileDTOModel? {
    let profileModel  = try await provider.requestAsync(.getProfile, decodeTo: ProfileModel.self)
    return profileModel.toProfileDTOModel()
  }
}
