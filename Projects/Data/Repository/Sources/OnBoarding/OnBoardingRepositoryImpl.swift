//
//  OnBoardingRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 12/30/25.
//

import Foundation

import DomainInterface
import Service
import Entity

@preconcurrency  import AsyncMoya

final public class OnBoardingRepositoryImpl: OnBoardingInterface {

  private let provider: MoyaProvider<OnBoardingService>

  public init(
    provider: MoyaProvider<OnBoardingService> = MoyaProvider<OnBoardingService>.default
  ) {
    self.provider = provider
  }

  // MARK: - 코드 검증
  public func verifyCode(
    code: String
  ) async throws -> VerifyCodeEntity {
    let dto: VerifyCodeDTO = try await provider.request(.verifyCode(code: code))
    return dto.toDomain()
  }

  // MARK: - 직군 선택
  public func fetchJobs() async throws -> [Entity.SelectJob] {
    let dtoArray: SelectJobsDTO = try await provider.request(.jobs)
    return dtoArray.data.toDomain()
  }

  // MARK: - 팀 선택
  public func fetchTeams(
    generationId: Int
  ) async throws -> [SelectTeamEntity] {
    let dto : SelectTeamsDTO = try await provider.request(.teams(generationId: generationId))
    return dto.data.toDomain()
  }

  // MARK: - 매니저 역활 선택
  public func fetchManaging() async throws -> [SelectManaging] {
    let dto: SelectMangerRoleDTO = try await provider.request(.mangerRole)
    return dto.data.toDomain()
  }

}
