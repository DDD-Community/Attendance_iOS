//
//  ScheduleUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model

import WeaveDI

public struct ScheduleUseCaseImpl: ScheduleInterface {
  @Dependency(\.scheduleRepository) var repository

  public init() { }

  // MARK: - 스케줄 조회
  public func getSchedules() async throws -> ScheduleModel? {
    return try await repository.getSchedules()
  }

  // MARK: - 스케줄 날짜 필터
  public func filtergetSchedules(
    startDate: String
  ) async throws -> ScheduleModel? {
    return try await repository.filtergetSchedules(startDate: startDate)
  }
}


extension ScheduleUseCaseImpl: DependencyKey {
  static public var liveValue: ScheduleInterface = ScheduleUseCaseImpl()
  static public var testValue: ScheduleInterface = ScheduleUseCaseImpl()
  static public var previewValue: ScheduleInterface = liveValue
}

public extension DependencyValues {
  var scheduleUseCase: ScheduleInterface {
    get { self[ScheduleUseCaseImpl.self] }
    set { self[ScheduleUseCaseImpl.self] = newValue }
  }
}
