//
//  ScheduleUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Entity
import WeaveDI

public struct ScheduleUseCaseImpl: ScheduleInterface {
  @Dependency(\.scheduleRepository) var repository

  public init() { }

  // MARK: - 스케줄 조회
  public func getSchedule() async throws -> [Schedule] {
    return try await repository.getSchedule()
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
