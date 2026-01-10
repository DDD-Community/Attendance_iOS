//
//  AttendanceUseCaseImpl.swift
//  UseCase
//
//  Created by Wonji Suh  on 7/23/25.
//

import DomainInterface
import Model
import Entity

import WeaveDI

public struct AttendanceUseCaseImpl: AttendanceInterface {
  @Dependency(\.attendanceRepository) var repository

  public init() { }


  public func adminAttendanceCount(scheduleId: Int) async throws -> Entity.AttendanceCount {
    return try await repository.adminAttendanceCount(scheduleId: scheduleId)
  }

  public func fetchAttendanceTeams() async throws -> [SelectTeamEntity] {
    return try await repository.fetchAttendanceTeams()
  }
}

extension AttendanceUseCaseImpl: DependencyKey {
  static public var liveValue: AttendanceInterface = AttendanceUseCaseImpl()
  static public var testValue:  AttendanceInterface = AttendanceUseCaseImpl()
  static public var previewValue: AttendanceInterface = liveValue
}

public extension DependencyValues {
  var attendanceUseCase: AttendanceInterface {
    get { self[AttendanceUseCaseImpl.self] }
    set { self[AttendanceUseCaseImpl.self] = newValue }
  }
}


