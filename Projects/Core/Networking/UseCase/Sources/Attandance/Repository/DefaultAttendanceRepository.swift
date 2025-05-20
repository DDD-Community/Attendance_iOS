//
//  DefaultAttendanceRepository.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/10/25.
//

import Model

final public class DefaultAttendanceRepository: AttendanceRepositoryProtocol  {
  public init() {}
  
  public func attendanceCount(
    startDate: String
  ) async throws -> AttendanceCountDTOModel? {
    return nil
  }
  
  public func getAttendances(
    startDate: String
  ) async throws -> Model.AttendanceCheckModel? {
    return nil
  }
  
  public func fillAttendance(
    team: Model.SelectTeam,
    startDate: String
  ) async throws -> Model.AttendanceCheckModel? {
    return nil
  }
  
  public func filterScheduleAttendance(
    userId: Int,
    scheduleId: String
  ) async throws -> AttendanceCheckModel? {
    return nil
  }
  
  public func modifyAttendance(
    attendanceId: String
  ) async throws -> ModifyAttendanceModel? {
    return nil
  }
}
