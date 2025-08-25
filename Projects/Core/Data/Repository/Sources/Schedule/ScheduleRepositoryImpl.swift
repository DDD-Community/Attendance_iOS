//
//  ScheduleRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

import Service

import AsyncMoya

@Observable
public class ScheduleRepositoryImpl: ScheduleInterface {

  fileprivate let provider = MoyaProvider<ScheduleService>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])

  public init(){}


  public func getSchedules() async throws -> ScheduleModel? {
    let scheduleModel = try await provider.requestAsync(.getSchedule, decodeTo: ScheduleDTOModel.self)
    return scheduleModel.toDomain()
  }

  public func filtergetSchedules(
    startDate: String
  ) async throws -> ScheduleModel? {
    let scheduleModel = try await provider.requestAsync(
      .filterSchedule(stratDate: startDate),decodeTo: ScheduleDTOModel.self)
    return scheduleModel.toDomain()
  }
}

