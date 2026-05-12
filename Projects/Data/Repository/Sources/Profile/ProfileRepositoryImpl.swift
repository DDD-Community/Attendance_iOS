//
//  ProfileRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh on 7/23/25.
//

import Combine
import Foundation

import ComposableArchitecture

// 프로젝트 모듈
import DomainInterface
import Entity
import Model
import Service

// 외부 의존성
import Moya

public final class ProfileRepositoryImpl: ProfileInterface, @unchecked Sendable {
  @Shared(.appStorage("staffRole")) var staffRole: Staff?
  @Dependency(\.profileLocalDataSource) private var localDataSource

  private let provider: MoyaProvider<ProfileService>

  public init(
    provider: MoyaProvider<ProfileService>? = nil
  ) {
    // 🚀 MoyaProviderPool 사용으로 메모리 최적화
    self.provider = provider ?? MoyaProviderPool.shared.authorizedProvider(for: ProfileService.self)
  }

  // MARK: - 프로필 조회

  // MARK: - 캐시 즉시 조회 (당일 만료, 네트워크 호출 없음)

  public func getCachedProfile() async -> Entity.ProfileEntity? {
    try? await localDataSource.loadUser()
  }

  // MARK: - 강제 refresh (캐시 무시, 항상 네트워크 + 캐시 저장)

  public func refreshProfile() async throws -> Entity.ProfileEntity {
    try await fetchAndCacheProfile()
  }

  public func getProfile() async throws -> Entity.ProfileEntity {
    // SWR: 캐시 hit이면 즉시 반환 + 백그라운드에서 fresh 갱신
    if let cached = try? await localDataSource.loadUser() {
      _Concurrency.Task.detached { [weak self] in
        _ = try? await self?.fetchAndCacheProfile()
      }
      return cached
    }

    // 캐시 miss → 네트워크 호출 후 캐시 저장
    return try await fetchAndCacheProfile()
  }

  private func fetchAndCacheProfile() async throws -> Entity.ProfileEntity {
    // 1. 저장된 역할 정보 확인
    // staffRole이 명확하게 있으면 해당 엔드포인트 호출
    if let role = staffRole {
      switch role {
      case .manager:
        let dto: ProfileDTO = try await provider.request(.getAdminProfile)
        let profile = dto.toDomain()
        try? await localDataSource.saveUser(profile)
        return profile
      case .member:
        let dto: ProfileDTO = try await provider.request(.getUserProfile)
        let profile = dto.toDomain()
        try? await localDataSource.saveUser(profile)
        return profile
      }
    }

    // 2. 역할 정보가 없으면, 유저 프로필을 먼저 시도 (가장 일반적인 케이스)
    // 실패 시 어드민 프로필 시도.
    do {
      let dto: ProfileDTO = try await provider.request(.getUserProfile)
      let profile = dto.toDomain()
      try? await localDataSource.saveUser(profile)
      return profile
    } catch {
      let dto: ProfileDTO = try await provider.request(.getAdminProfile)
      let profile = dto.toDomain()
      try? await localDataSource.saveUser(profile)
      return profile
    }
  }

  // MARK: - 프로필 수정

  public func editProfile(
    input: EditProfileInput
  ) async throws -> Entity.ProfileEntity {
    let body = input.toRequestDTO()
    let dto: ProfileDTO = try await provider.request(.editProfile(body: body))
    let profile = dto.toDomain()
    try? await localDataSource.saveUser(profile)
    return profile
  }
}
