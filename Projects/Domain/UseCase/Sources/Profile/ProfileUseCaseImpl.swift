//
//  ProfileUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//
import DomainInterface
import Model

import WeaveDI

public struct ProfileUseCaseImpl: ProfileInterface {
  @Dependency(\.profileRepository) var repository

  public init() { }
  // MARK: - 프로필  수정
  public func editProfileManger(
    name: String,
    inviteCode: String,
    role: String,
    team: String,
    responsibility: String
  ) async throws -> ProfileResponseModel? {
    return try await repository.editProfileManger(
      name: name,
      inviteCode: inviteCode,
      role: role,
      team: team,
      responsibility: responsibility
    )
  }
  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileResponseModel? {
    return try await repository.getProfile()
  }

  // MARK: - 프로필수정 운영진 팀 없을때
  public func editProfileMangerNoTeam(
    name: String,
    inviteCode: String,
    role: String,
    responsibility: String
  ) async throws -> ProfileResponseModel? {
    return try await repository.editProfileMangerNoTeam(
      name: name,
      inviteCode: inviteCode,
      role: role,
      responsibility: responsibility
    )
  }

  // MARK: - 프로필 수정 멤버
  public func editProfileMember(
    name: String,
    inviteCode: String,
    role: String,
    team: String
  ) async throws -> ProfileResponseModel? {
    return try await repository.editProfileMember(
      name: name,
      inviteCode: inviteCode,
      role: role,
      team: team
    )
  }
}

extension ProfileUseCaseImpl: DependencyKey {
  static public var liveValue: ProfileInterface = ProfileUseCaseImpl()
  static public var testValue: ProfileInterface = ProfileUseCaseImpl()
  static public var previewValue: ProfileInterface = liveValue
}

public extension DependencyValues {
  var profileUseCase: ProfileInterface {
    get { self[ProfileUseCaseImpl.self] }
    set { self[ProfileUseCaseImpl.self] = newValue }
  }
}

