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

@preconcurrency import AsyncMoya

@Observable
final public class ProfileRepositoryImpl: ProfileInterface , Sendable{

  private let provider: MoyaProvider<ProfileService>

  public init(
    provider: MoyaProvider<ProfileService> = MoyaProvider<ProfileService>.authorized
  ) {
    self.provider = provider
  }


  // MARK: - 프로필 조회
  public func getProfile() async throws -> Entity.ProfileEntity {
    let dto:ProfileDTO = try await provider.request(.getProfile)
    return dto.toDomain()
  }
}
