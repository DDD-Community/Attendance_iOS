//
//  ProfileUseCaseInterface.swift
//  ProfileDomainInterface
//
//  Created by DDD on 9/3/26.
//

import Dependencies

public protocol ProfileUseCaseInterface: Sendable {
  func getProfile() async throws(ProfileError) -> ProfileEntity
  func getCachedProfile() async -> ProfileEntity?
  func refreshProfile() async throws(ProfileError) -> ProfileEntity
  func editProfile(input: EditProfileInput) async throws(EditProfileError) -> ProfileEntity
}

extension MockProfileRepository: ProfileUseCaseInterface {}

public enum ProfileUseCaseDependency: TestDependencyKey {
  public static let testValue: any ProfileUseCaseInterface = MockProfileRepository()
  public static let previewValue: any ProfileUseCaseInterface = testValue
}

public extension DependencyValues {
  var profileUseCase: any ProfileUseCaseInterface {
    get { self[ProfileUseCaseDependency.self] }
    set { self[ProfileUseCaseDependency.self] = newValue }
  }
}
