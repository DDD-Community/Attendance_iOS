//
//  ScheduleRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

import Foundation

import DDDNetworkInterface
import DomainInterface
import Entity
import Model
import APIEndpoint

import Dependencies

public final class ScheduleRepositoryImpl: ScheduleInterface, @unchecked Sendable {
  @Dependency(\.scheduleLocalDataSource) private var localDataSource

  private let client: any DDDNetworkClient

  public init(
    client: any DDDNetworkClient
  ) {
    self.client = client
  }

  public func getCachedSchedule() async -> [Schedule]? {
    try? await localDataSource.loadAll()
  }

  public func getSchedule() async throws(ScheduleError) -> [Schedule] {
    // SWR: 캐시 hit이면 즉시 반환 + 백그라운드에서 fresh 갱신
    if let cached = try? await localDataSource.loadAll(), !cached.isEmpty {
      _Concurrency.Task.detached { [weak self] in
        _ = try? await self?.fetchAndCacheSchedule()
      }
      return cached
    }

    do {
      return try await fetchAndCacheSchedule()
    } catch {
      throw ScheduleError.from(error)
    }
  }

  private func fetchAndCacheSchedule() async throws(ScheduleError) -> [Schedule] {
    do {
      let dto = try await client.send(
        ScheduleRequest.getSchedule,
        as: ScheduleDTO.self
      )
      let schedules = dto.toDomain().sortedByDate()
      try? await localDataSource.saveAll(schedules)
      return schedules
    } catch {
      throw ScheduleError.from(error)
    }
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
