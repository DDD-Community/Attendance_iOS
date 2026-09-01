//
//  ProfileRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

import Combine
import Foundation

import ComposableArchitecture

// 프로젝트 모듈
import DDDNetworkInterface
import DomainInterface
import Entity
import Model
import APIEndpoint

public final class ProfileRepositoryImpl: ProfileInterface, @unchecked Sendable {
  @Shared(.appStorage("staffRole")) var staffRole: Staff?
  @Dependency(\.profileLocalDataSource) private var localDataSource

  private let client: any DDDNetworkClient

  public init(
    client: any DDDNetworkClient
  ) {
    self.client = client
  }

  // MARK: - 프로필 조회

  // MARK: - 캐시 즉시 조회 (당일 만료, 네트워크 호출 없음)
  public func getCachedProfile() async -> Entity.ProfileEntity? {
    try? await localDataSource.loadUser()
  }

  // MARK: - 강제 refresh (캐시 무시, 항상 네트워크 + 캐시 저장)

  public func refreshProfile() async throws(ProfileError) -> Entity.ProfileEntity {
    do {
      return try await fetchAndCacheProfile()
    } catch {
      throw ProfileError.from(error)
    }
  }

  public func getProfile() async throws(ProfileError) -> Entity.ProfileEntity {
    // SWR: 캐시 hit이면 즉시 반환 + 백그라운드에서 fresh 갱신
    if let cached = try? await localDataSource.loadUser() {
      _Concurrency.Task.detached { [weak self] in
        _ = try? await self?.fetchAndCacheProfile()
      }
      return cached
    }

    // 캐시 miss → 네트워크 호출 후 캐시 저장
    do {
      return try await fetchAndCacheProfile()
    } catch {
      throw ProfileError.from(error)
    }
  }

  private func fetchAndCacheProfile() async throws(ProfileError) -> Entity.ProfileEntity {
    // 1. 저장된 역할 정보 확인
    // staffRole이 명확하게 있으면 해당 엔드포인트 호출
    if let role = staffRole {
      switch role {
      case .manager:
        do {
          let dto = try await client.send(ProfileService.getAdminProfile, as: ProfileDTO.self)
          let profile = dto.toDomain()
          try? await localDataSource.saveUser(profile)
          return profile
        } catch {
          throw ProfileError.from(error)
        }
      case .member:
        do {
          let dto = try await client.send(ProfileService.getUserProfile, as: ProfileDTO.self)
          let profile = dto.toDomain()
          try? await localDataSource.saveUser(profile)
          return profile
        } catch {
          throw ProfileError.from(error)
        }
      }
    }

    // 2. 역할 정보가 없으면, 유저 프로필을 먼저 시도 (가장 일반적인 케이스)
    // 실패 시 어드민 프로필 시도.
    do {
      let dto = try await client.send(ProfileService.getUserProfile, as: ProfileDTO.self)
      let profile = dto.toDomain()
      try? await localDataSource.saveUser(profile)
      return profile
    } catch {
      do {
        let dto = try await client.send(ProfileService.getAdminProfile, as: ProfileDTO.self)
        let profile = dto.toDomain()
        try? await localDataSource.saveUser(profile)
        return profile
      } catch {
        throw ProfileError.from(error)
      }
    }
  }

  // MARK: - 프로필 수정

  public func editProfile(
    input: EditProfileInput
  ) async throws(EditProfileError) -> Entity.ProfileEntity {
    do {
      let body = input.toRequestDTO()
      let dto = try await client.send(ProfileService.editProfile(body: body), as: ProfileDTO.self)
      let profile = dto.toDomain()
      try? await localDataSource.saveUser(profile)
      return profile
    } catch {
      throw EditProfileError.from(error)
    }
  }
}
