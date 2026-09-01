//
//  ScheduleUseCaseImpl.swift
//  UseCase
//
//  Created by DDD on 7/23/25.
//

import Dependencies
import DomainInterface
import Entity
import Model

public struct ScheduleUseCaseImpl: ScheduleInterface {
  @Dependency(\.scheduleRepository) var repository

  public init() {}

  // MARK: - 캐시 즉시 조회 (만료 시 nil)

  public func getCachedSchedule() async -> [Schedule]? {
    await repository.getCachedSchedule()
  }

  // MARK: - 스케줄 조회

  public func getSchedule() async throws(ScheduleError) -> [Schedule] {
    return try await repository.getSchedule()
  }
}

extension ScheduleUseCaseImpl: DependencyKey {
  public static var liveValue: ScheduleInterface = ScheduleUseCaseImpl()
  public static var testValue: ScheduleInterface = ScheduleUseCaseImpl()
  public static var previewValue: ScheduleInterface = liveValue
}

public extension DependencyValues {
  var scheduleUseCase: ScheduleInterface {
    get { self[ScheduleUseCaseImpl.self] }
    set { self[ScheduleUseCaseImpl.self] = newValue }
  }
}
