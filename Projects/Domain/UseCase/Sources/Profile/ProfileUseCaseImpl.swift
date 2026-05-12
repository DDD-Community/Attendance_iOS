//
//  ProfileUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//
import DomainInterface
import Model

import ComposableArchitecture
import Entity
import WeaveDI

public protocol ProfileUseCaseInterface: Sendable {
  func getProfile() async throws -> ProfileEntity
  func getCachedProfile() async -> ProfileEntity?
  func refreshProfile() async throws -> ProfileEntity
  func editUser(
    userSession: UserSession
  ) async throws -> ProfileEntity
}

public struct ProfileUseCaseImpl: ProfileUseCaseInterface {
  @Dependency(\.profileRepository) var repository
  @Shared(.appStorage("staffRole")) var staffRole: Staff?
  @Shared(.inMemory("UserSession")) var userSession: UserSession = .empty

  public init() {}

  // MARK: - 프로필  수정

  // MARK: - 캐시 즉시 조회 (만료 시 nil)

  public func getCachedProfile() async -> ProfileEntity? {
    await repository.getCachedProfile()
  }

  // MARK: - 강제 새로고침 (캐시 무시, 네트워크)

  public func refreshProfile() async throws -> ProfileEntity {
    let profile = try await repository.refreshProfile()
    $staffRole.withLock { $0 = profile.role }
    $userSession.withLock {
      $0.userID = profile.userID
      $0.name = profile.name
      $0.generation = profile.generation
      $0.selectTeam = profile.team ?? .unknown
      $0.selectPart = profile.jobRole
      $0.userRole = profile.role
      $0.managing = profile.manger ?? []
    }
    return profile
  }

  // MARK: - 프로필 조회

  public func getProfile() async throws -> ProfileEntity {
    let profileResult = try await repository.getProfile()
    $staffRole.withLock {
      $0 = profileResult.role
    }
    $userSession.withLock {
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
    $staffRole.withLock {
      $0 = editProfile.role
    }
    return editProfile
  }
}

extension ProfileUseCaseImpl: DependencyKey {
  public static var liveValue: ProfileUseCaseInterface = ProfileUseCaseImpl()
  public static var testValue: ProfileUseCaseInterface = ProfileUseCaseImpl()
  public static var previewValue: ProfileUseCaseInterface = liveValue
}

public extension DependencyValues {
  var profileUseCase: ProfileUseCaseInterface {
    get { self[ProfileUseCaseImpl.self] }
    set { self[ProfileUseCaseImpl.self] = newValue }
  }
}
