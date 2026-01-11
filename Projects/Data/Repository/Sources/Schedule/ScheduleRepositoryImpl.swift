//
//  ScheduleRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Entity
import Service

@preconcurrency import AsyncMoya

@Observable
final public class ScheduleRepositoryImpl: ScheduleInterface {

  private let provider: MoyaProvider<ScheduleService>

  public init(
    provider: MoyaProvider<ScheduleService> = MoyaProvider<ScheduleService>.authorized
  ) {
    self.provider = provider
  }

  public func getSchedule() async throws -> [Schedule] {
    let dto: ScheduleDTO = try await provider.request(.getSchedule)
    return dto.toDomain()
  }

}
