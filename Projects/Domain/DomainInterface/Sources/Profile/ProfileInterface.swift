//
//  ProfileInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Updated for WeaveDI v4.0 - Protocol-based DI Registration
//

import Entity
import Foundation
import WeaveDI

/// Profile 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol ProfileInterface: Sendable {
  func getProfile() async throws -> ProfileEntity
  func getCachedProfile() async -> ProfileEntity?
  func refreshProfile() async throws -> ProfileEntity
  func editProfile(input: EditProfileInput) async throws -> ProfileEntity
}

/// Profile Repository의 DependencyKey 구조체
public struct ProfileRepositoryDependency: DependencyKey {
  public static var liveValue: ProfileInterface {
    UnifiedDI.resolve(ProfileInterface.self) ?? DefaultProfileRepositoryImpl()
  }

  public static var testValue: ProfileInterface {
    UnifiedDI.resolve(ProfileInterface.self) ?? DefaultProfileRepositoryImpl()
  }

  public static var previewValue: ProfileInterface = liveValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var profileRepository: ProfileInterface {
    get { self[ProfileRepositoryDependency.self] }
    set { self[ProfileRepositoryDependency.self] = newValue }
  }
}
