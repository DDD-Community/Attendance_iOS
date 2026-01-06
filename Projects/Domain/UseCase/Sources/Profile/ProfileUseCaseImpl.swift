//
//  ProfileUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//
import DomainInterface
import Model

import WeaveDI
import Entity

public protocol ProfileUseCaseInterface: Sendable {
  func getProfile() async throws -> ProfileEntity
  func editUser(
    userSession: UserSession
  ) async throws -> ProfileEntity
}


public struct ProfileUseCaseImpl: ProfileUseCaseInterface {
  @Dependency(\.profileRepository) var repository

  public init() { }
  // MARK: - 프로필  수정

  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileEntity {
    return try await repository.getProfile()
  }

  public func editUser(
    userSession: UserSession
  ) async throws -> ProfileEntity {
    let input = EditProfileInput(
      name: userSession.name,
      generationId: userSession.generationId,
      jobRole: userSession.selectPart,
      teamId: userSession.selectTeamId,
      managerRoles: userSession.managing,
      inviteCode: userSession.inviteCode
    )
    return try await editProfile(input: input)
  }

  public func editProfile(input: EditProfileInput) async throws -> ProfileEntity {
    return try await repository.editProfile(input: input)
  }

}

extension ProfileUseCaseImpl: DependencyKey {
  static public var liveValue: ProfileUseCaseInterface = ProfileUseCaseImpl()
  static public var testValue: ProfileUseCaseInterface = ProfileUseCaseImpl()
  static public var previewValue: ProfileUseCaseInterface = liveValue
}

public extension DependencyValues {
  var profileUseCase: ProfileUseCaseInterface {
    get { self[ProfileUseCaseImpl.self] }
    set { self[ProfileUseCaseImpl.self] = newValue }
  }
}

