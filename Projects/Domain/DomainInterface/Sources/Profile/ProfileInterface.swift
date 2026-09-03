//
//  ProfileInterface.swift
//  DomainInterface
//
//  Created by DDD on 7/23/25.
//

import Entity
import Foundation

import Dependencies

/// Profile 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol ProfileInterface: Sendable {
  func getProfile() async throws(ProfileError) -> ProfileEntity
  func getCachedProfile() async -> ProfileEntity?
  func refreshProfile() async throws(ProfileError) -> ProfileEntity
  func editProfile(input: EditProfileInput) async throws(EditProfileError) -> ProfileEntity
}

/// Profile Repository의 DependencyKey 구조체
public enum ProfileRepositoryDependency: TestDependencyKey {

  public static var testValue: ProfileInterface {
    MockProfileRepository()
  }

  public static var previewValue: ProfileInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var profileRepository: ProfileInterface {
    get { self[ProfileRepositoryDependency.self] }
    set { self[ProfileRepositoryDependency.self] = newValue }
  }
}
