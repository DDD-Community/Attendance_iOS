//
//  ProfileRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import Combine

import DomainInterface
import Model
import Service
import Foundations

@preconcurrency import AsyncMoya

@Observable
final public class ProfileRepositoryImpl: ProfileInterface , Sendable{

  private let provider: MoyaProvider<ProfileService>

  public init(
    provider: MoyaProvider<ProfileService> = MoyaProvider<ProfileService>.authorized
  ) {
    self.provider = provider
  }



  // MARK: - 프로필 수정
  public func editProfileManger(
    name: String,
    inviteCode: String,
    role: String,
    team: String,
    responsibility: String
  ) async throws -> ProfileResponseModel? {
    let response: BaseResponseDTO<ProfileResponseDTO> = try await provider.request(
      .editProfileManger(
        username: name,
        inviteCodeId: inviteCode,
        role: role,
        team:team,
        responsibility: responsibility
      ),
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
    let response: BaseResponseDTO<ProfileResponseDTO> = try await provider.request(
      .editProfileMangerNoTeam(
        username: name,
        inviteCodeId: inviteCode,
        role: role,
        responsibility: responsibility
      ),
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
    let response: BaseResponseDTO<ProfileResponseDTO> = try await provider.request(
      .editProfileMember(
        username: name,
        inviteCodeId: inviteCode,
        role: role,
        team: team
      ),
    )
    return response.data.toDomain()
  }

  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileResponseModel? {
    let response: BaseResponseDTO<ProfileResponseDTO> = try await provider.request(.getProfile)
    return response.data.toDomain()
  }
}
