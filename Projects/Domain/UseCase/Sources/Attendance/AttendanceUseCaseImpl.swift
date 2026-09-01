//
//  AttendanceUseCaseImpl.swift
//  UseCase
//
//  Created by DDD on 7/23/25.
//

import Dependencies
import DomainInterface
import Model
import Entity


public struct AttendanceUseCaseImpl: AttendanceInterface {
  @Dependency(\.attendanceRepository) var repository
  
  public init() { }


  public func adminAttendanceCount(scheduleId: Int) async throws(AttendanceError) -> Entity.AttendanceCount {
    return try await repository.adminAttendanceCount(scheduleId: scheduleId)
  }

  public func fetchAttendanceTeams() async throws(AttendanceError) -> [SelectTeamEntity] {
    return try await repository.fetchAttendanceTeams()
  }

  public func sessionAttendance(
    scheduleId: Int,
    teamId: Int
  ) async throws(AttendanceError) -> [Attendance] {
    return try await repository.sessionAttendance(scheduleId: scheduleId, teamId: teamId)
  }

  public func fetchStatus() async throws(AttendanceError) -> [AttendanceStatus] {
    return try await repository.fetchStatus()
  }

  public func editAttendance(
    input: EditAttendanceInput
  ) async throws(AttendanceError) -> EditAttendance {
    return try await repository.editAttendance(input: input)
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
