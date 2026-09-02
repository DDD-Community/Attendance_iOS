//
//  DefaultScheduleRepositoryImpl.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

import Entity

public final class DefaultScheduleRepositoryImpl: ScheduleInterface {
  public init() {}

  public func getCachedSchedule() async -> [Schedule]? {
    nil
  }

  public func getSchedule() async throws(ScheduleError) -> [Schedule] {
    return [
      Schedule(
        id: 1,
        name: "팀 회의",
        description: "주간 팀 회의 및 프로젝트 진행상황 공유",
        month: 1,
        day: 15,
        year: 2026
      )
    ]
  }
}
