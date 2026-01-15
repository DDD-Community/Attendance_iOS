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
import ComposableArchitecture

public protocol ProfileUseCaseInterface: Sendable {
  func getProfile() async throws -> ProfileEntity
  func editUser(
    userSession: UserSession
  ) async throws -> ProfileEntity
}


public struct ProfileUseCaseImpl: ProfileUseCaseInterface {
  @Dependency(\.profileRepository) var repository
  @Shared(.appStorage("staffRole")) var staffRole: Staff?
  @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty

  public init() { }
  // MARK: - 프로필  수정

  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileEntity {
    let profileResult = try await repository.getProfile()
    self.$staffRole.withLock {
      $0 = profileResult.role
    }
    self.$userSession.withLock {
      $0.userID = profileResult.userID
      $0.name = profileResult.name
      $0.generation = profileResult.generation
      $0.selectTeam = profileResult.team ?? .unknown
      $0.selectPart = profileResult.jobRole
      $0.userRole = profileResult.role
      $0.managing = profileResult.manger ?? []
    }
    return profileResult

  }

  public func editUser(
    userSession: UserSession
  ) async throws -> ProfileEntity {
    let isManager = userSession.userRole == .manager
    let input = EditProfileInput(
      name: userSession.name,
      generationId: userSession.generationId,
      jobRole: userSession.selectPart,
      teamId: userSession.selectTeamId,
      managerRoles: isManager ? userSession.managing : nil,
      inviteCode: userSession.inviteCode
    )
    return try await editProfile(input: input)
  }

  public func editProfile(input: EditProfileInput) async throws -> ProfileEntity {
    let editProfile = try await repository.editProfile(input: input)
    self.$staffRole.withLock {
      $0 = editProfile.role
    }
    return editProfile
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

