//
//  ScheduleRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import Foundation

import DomainInterface
import Entity
import Model
import Service

import Dependencies

@preconcurrency import AsyncMoya

public final class ScheduleRepositoryImpl: ScheduleInterface, @unchecked Sendable {
  @Dependency(\.scheduleLocalDataSource) private var localDataSource

  private let provider: MoyaProvider<ScheduleService>

  public init(
    provider: MoyaProvider<ScheduleService> = MoyaProvider<ScheduleService>.authorized
  ) {
    self.provider = provider
  }

  public func getCachedSchedule() async -> [Schedule]? {
    try? await localDataSource.loadAll()
  }

  public func getSchedule() async throws -> [Schedule] {
    // SWR: 캐시 hit이면 즉시 반환 + 백그라운드에서 fresh 갱신
    if let cached = try? await localDataSource.loadAll(), !cached.isEmpty {
      _Concurrency.Task.detached { [weak self] in
        _ = try? await self?.fetchAndCacheSchedule()
      }
      return cached
    }

    return try await fetchAndCacheSchedule()
  }

  private func fetchAndCacheSchedule() async throws -> [Schedule] {
    let dto: ScheduleDTO = try await provider.request(.getSchedule)
    let schedules = dto.toDomain().sortedByDate()
    try? await localDataSource.saveAll(schedules)
    return schedules
  }
}

private extension Array where Element == Schedule {
  func sortedByDate() -> [Schedule] {
    sorted { lhs, rhs in
      if lhs.year != rhs.year { return lhs.year < rhs.year }
      if lhs.month != rhs.month { return lhs.month < rhs.month }
      return lhs.day < rhs.day
    }
  }
}
