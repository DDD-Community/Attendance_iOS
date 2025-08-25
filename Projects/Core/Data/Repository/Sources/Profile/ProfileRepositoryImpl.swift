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

import AsyncMoya

@Observable
public class ProfileRepositoryImpl: ProfileInterface {

  public init() {}

  private let provider = MoyaProvider<ProfileService>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])

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
      decodeTo:  BaseResponseDTO<ProfileResponseDTO>.self
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
      decodeTo: BaseResponseDTO<ProfileResponseDTO>.self
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
      decodeTo:  BaseResponseDTO<ProfileResponseDTO>.self
    )
    return response.data.toDomain()
  }

  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileResponseModel? {
    let response = try await provider.requestAsync(.getProfile, decodeTo:  BaseResponseDTO<ProfileResponseDTO>.self)
    return response.data.toDomain()
  }
}

