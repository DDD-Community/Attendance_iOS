//
//  ProfileUseCaseImpl.swift
//  ProfileDomain
//
//  Created by DDD on 7/23/25.
//
import AuthDomainInterface
import ProfileDomainInterface

import ComposableArchitecture

public struct ProfileUseCaseImpl: ProfileUseCaseInterface {
  @Dependency(\.profileRepository) var repository
  @Shared(.staffRole) var staffRole
  @Shared(.userSession) var userSession

  public init() {}

  // MARK: - 프로필  수정

  // MARK: - 캐시 즉시 조회 (만료 시 nil)

  public func getCachedProfile() async -> ProfileEntity? {
    await repository.getCachedProfile()
  }

  // MARK: - 강제 새로고침 (캐시 무시, 네트워크)

  public func refreshProfile() async throws(ProfileError) -> ProfileEntity {
    let profile = try await repository.refreshProfile()
    syncProfileSession(with: profile)
    return profile
  }

  // MARK: - 프로필 조회

  public func getProfile() async throws(ProfileError) -> ProfileEntity {
    let profileResult = try await repository.getProfile()
    syncProfileSession(with: profileResult)
    return profileResult
  }

  public func editUser(
    userSession: UserSession
  ) async throws(EditProfileError) -> ProfileEntity {
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

  public func editProfile(input: EditProfileInput) async throws(EditProfileError) -> ProfileEntity {
    let editProfile = try await repository.editProfile(input: input)
    syncProfileSession(
      with: editProfile,
      generationId: input.generationId,
      inviteCode: input.inviteCode
    )
    return editProfile
  }

  private func syncProfileSession(
    with profile: ProfileEntity,
    generationId: Int? = nil,
    inviteCode: String? = nil
  ) {
    $staffRole.withLock {
      $0 = profile.role
    }
    $userSession.withLock {
      $0.userID = profile.userID
      $0.name = profile.name
      $0.generation = profile.generation
      $0.selectTeam = profile.team ?? .unknown
      $0.selectPart = profile.jobRole
      $0.userRole = profile.role
      $0.managing = profile.manger ?? []

      if let generationId {
        $0.generationId = generationId
      }

      if let inviteCode {
        $0.inviteCode = inviteCode
      }
    }
  }
}
