//
//  ScheduleRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

import Service

@preconcurrency import AsyncMoya

@Observable
final public class ScheduleRepositoryImpl: ScheduleInterface {

  private let provider: MoyaProvider<ScheduleService>

  public init(
    provider: MoyaProvider<ScheduleService> = MoyaProvider<ScheduleService>.withSession(AuthInterceptor.shared)
  ) {
    self.provider = provider
  }

  public func getSchedules() async throws -> ScheduleModel? {
    let scheduleModel: ScheduleDTOModel = try await provider.request(.getSchedule)
    return scheduleModel.toDomain()
  }

  public func filtergetSchedules(
    startDate: String
  ) async throws -> ScheduleModel? {
    let scheduleModel: ScheduleDTOModel = try await provider.request(
      .filterSchedule(stratDate: startDate))
    return scheduleModel.toDomain()
  }
}

