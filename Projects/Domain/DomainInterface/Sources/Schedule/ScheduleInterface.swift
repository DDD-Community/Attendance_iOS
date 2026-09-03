//
//  ScheduleInterface.swift
//  DomainInterface
//
//  Created by DDD on 7/23/25.
//

import Entity
import Foundation

import Dependencies

/// Schedule 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol ScheduleInterface: Sendable {
  func getSchedule() async throws(ScheduleError) -> [Schedule]
  func getCachedSchedule() async -> [Schedule]?
}

/// Schedule Repository의 DependencyKey 구조체
public enum ScheduleRepositoryDependency: TestDependencyKey {

  public static var testValue: ScheduleInterface {
    MockScheduleRepository()
  }

  public static var previewValue: ScheduleInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var scheduleRepository: ScheduleInterface {
    get { self[ScheduleRepositoryDependency.self] }
    set { self[ScheduleRepositoryDependency.self] = newValue }
  }
}
