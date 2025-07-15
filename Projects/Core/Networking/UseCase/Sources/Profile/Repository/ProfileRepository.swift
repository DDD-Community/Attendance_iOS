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

fileprivate typealias Response = BaseResponseDTO<ProfileResponseDTO>

@Observable
public class ProfileRepository: ProfileRepositoryProtocol {

  public init() {}

  private let provider = MoyaProvider<ProfileService>(plugins: [MoyaLoggingPlugin()])

  // MARK: - 프로필 수정
  public func editProfileManger(
    name: String,
    inviteCode: String,
    role: String,
    team: String,
    responsibility: String
  ) async throws -> ProfileResponseModel? {
    let response = try await provider.requestAsync(
      .editProfileManger(
        username: name,
        inviteCodeId: inviteCode,
        role: role,
        team:team,
        responsibility: responsibility
      ),
      decodeTo: Response.self
    )
    return response.data.toDomain()
  }
  
  // MARK: - 프로필 수정 운영진
  public func editProfileMangerNoTeam(
    name: String,
    inviteCode: String,
    role: String,
    responsibility: String
  ) async throws -> ProfileResponseModel? {
    let response = try await provider.requestAsync(
      .editProfileMangerNoTeam(
        username: name,
        inviteCodeId: inviteCode,
        role: role,
        responsibility: responsibility
      ),
      decodeTo: Response.self
    )
    return response.data.toDomain()
  }
  
  // MARK: - 멤버 프로필 수정
  public func editProfileMember(
    name: String,
    inviteCode: String,
    role: String,
    team: String
  ) async throws -> ProfileResponseModel? {
    let response = try await provider.requestAsync(
      .editProfileMember(
        username: name,
        inviteCodeId: inviteCode,
        role: role,
        team: team
      ),
      decodeTo: Response.self
    )
    return response.data.toDomain()
  }

  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileResponseModel? {
    let response = try await provider.requestAsync(.getProfile, decodeTo: Response.self)
    return response.data.toDomain()
  }
}
