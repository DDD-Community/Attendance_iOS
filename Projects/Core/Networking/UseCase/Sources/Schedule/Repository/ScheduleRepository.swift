//
//  ScheduleRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/9/25.
//

import Model

import Service

import AsyncMoya

@Observable
public class ScheduleRepository: ScheduleRepositoryProtocol {
 
  fileprivate let provider = MoyaProvider<ScheduleService>(plugins: [MoyaLoggingPlugin()])
  
  public init(){}
  
  
  public func getSchedules() async throws -> ScheduleDTOModel? {
    let scheduleModel = try await provider.requestAsync(.getSchedule, decodeTo: ScheduleModel.self)
    return scheduleModel.toScheduleDTOModel()
  }
}
