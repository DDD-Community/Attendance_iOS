//
//  OnBoardingRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 12/30/25.
//

import Foundation

import DDDNetworkInterface
import DomainInterface
import Entity
import APIEndpoint

final public class OnBoardingRepositoryImpl: OnBoardingInterface {

  private let client: any DDDNetworkClient

  public init(
    client: any DDDNetworkClient
  ) {
    self.client = client
  }

  // MARK: - 코드 검증
  public func verifyCode(
    code: String
  ) async throws -> VerifyCodeEntity {
    let dto = try await client.send(
      OnBoardingService.verifyCode(code: code),
      as: VerifyCodeDTO.self
    )
    return dto.toDomain()
  }

  // MARK: - 직군 선택
  public func fetchJobs() async throws -> [Entity.SelectJob] {
    let dtoArray = try await client.send(
      OnBoardingService.jobs,
      as: SelectJobsDTO.self
    )
    return dtoArray.data.toDomain()
  }

  // MARK: - 팀 선택
  public func fetchTeams(
    generationId: Int
  ) async throws -> [SelectTeamEntity] {
    let dto = try await client.send(
      OnBoardingService.teams(generationId: generationId),
      as: SelectTeamsDTO.self
    )
    return dto.data.toDomain()
  }

  // MARK: - 매니저 역활 선택
  public func fetchManaging() async throws -> [SelectManaging] {
    let dto = try await client.send(
      OnBoardingService.mangerRole,
      as: SelectMangerRoleDTO.self
    )
    return dto.data.toDomain()
  }

}
