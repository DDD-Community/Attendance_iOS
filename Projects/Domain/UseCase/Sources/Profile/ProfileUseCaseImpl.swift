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

public struct ProfileUseCaseImpl: ProfileInterface {
  @Dependency(\.profileRepository) var repository

  public init() { }
  // MARK: - 프로필  수정

  // MARK: - 프로필 조회
  public func getProfile() async throws -> ProfileEntity {
    return try await repository.getProfile()
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

