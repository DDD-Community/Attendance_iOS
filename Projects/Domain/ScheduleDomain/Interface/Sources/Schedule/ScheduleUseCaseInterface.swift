//
//  ScheduleUseCaseInterface.swift
//  ScheduleDomainInterface
//
//  Created by DDD on 9/3/26.
//

import Dependencies

public protocol ScheduleUseCaseInterface: Sendable {
  func getSchedule() async throws(ScheduleError) -> [Schedule]
  func getCachedSchedule() async -> [Schedule]?
}

extension MockScheduleRepository: ScheduleUseCaseInterface {}

public enum ScheduleUseCaseDependency: TestDependencyKey {
  public static let testValue: any ScheduleUseCaseInterface = MockScheduleRepository()
  public static let previewValue: any ScheduleUseCaseInterface = testValue
}

public extension DependencyValues {
  var scheduleUseCase: any ScheduleUseCaseInterface {
    get { self[ScheduleUseCaseDependency.self] }
    set { self[ScheduleUseCaseDependency.self] = newValue }
  }
}
