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
import Entity
import ComposableArchitecture

@preconcurrency import AsyncMoya

final public class ProfileRepositoryImpl: ProfileInterface , @unchecked Sendable{
  @Shared(.appStorage("staffRole")) var staffRole: Staff?

  private let provider: MoyaProvider<ProfileService>

  public init(
    provider: MoyaProvider<ProfileService> = MoyaProvider<ProfileService>.authorized
  ) {
    self.provider = provider
  }


  // MARK: - 프로필 조회
  public func getProfile() async throws -> Entity.ProfileEntity {
    $staffRole.withLock { $0 = nil }
    if staffRole == .manager {
      let dto:ProfileDTO = try await provider.request(.getAdminProfile)
      return dto.toDomain()
    } else if staffRole == .member {
      let dto:ProfileDTO = try await provider.request(.getUserProfile)
      return dto.toDomain()
    }
    else {
      do {
        let dto:ProfileDTO = try await provider.request(.getUserProfile)
        return dto.toDomain()
      } catch {
        let dto:ProfileDTO = try await provider.request(.getAdminProfile)
        return dto.toDomain()
      }
    }
  }

  // MARK: - 프로필 수정
  public func editProfile(
    input: EditProfileInput
  ) async throws -> Entity.ProfileEntity {
    let body = input.toRequestDTO()
    let dto: ProfileDTO = try await provider.request(.editProfile(body: body))
    return dto.toDomain()
  }
}
