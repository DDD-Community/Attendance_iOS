//
//  ScheduleInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//  Updated for WeaveDI v4.0 - Protocol-based DI Registration
//

import Foundation
import WeaveDI

/// Schedule 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol ScheduleInterface: Sendable {
  func getSchedules()  async throws -> ScheduleModel?
  func filtergetSchedules(startDate: String) async throws -> ScheduleModel?
}

/// Schedule Repository의 DependencyKey 구조체
public struct ScheduleRepositoryDependency: DependencyKey {
  public static var liveValue: ScheduleInterface {
    UnifiedDI.resolve(ScheduleInterface.self) ?? DefaultScheduleRepositoryImpl()
  }

  public static var testValue: ScheduleInterface {
    UnifiedDI.resolve(ScheduleInterface.self) ?? DefaultScheduleRepositoryImpl()
  }

  public static var previewValue: ScheduleInterface = liveValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var scheduleRepository: ScheduleInterface {
    get { self[ScheduleRepositoryDependency.self] }
    set { self[ScheduleRepositoryDependency.self] = newValue }
  }
}
