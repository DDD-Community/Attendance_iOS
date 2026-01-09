//
//  DefaultAttendanceRepositoryImpl.swift
//  Repository
//
//  Created by Wonji Suh  on 7/23/25.
//

import Model

final public class DefaultAttendanceRepositoryImpl: AttendanceInterface  {
  public init() {}

  public func attendanceCount(
    startDate: String
  ) async throws -> AttendanceCountResponseModel? {
    return nil
  }

  public func getAttendances(
    startDate: String,
    endDate: String
  ) async throws -> AttendanceListModel? {
    return nil
  }

  public func fillAttendance(
    team: SelectTeam,
    startDate: String
  ) async throws -> AttendanceListModel? {
    return nil
  }

  public func filterScheduleAttendance(
    userId: Int,
    scheduleId: String,
    startDate: String
  ) async throws -> AttendanceListModel? {
    return nil
  }

  public func modifyAttendance(
    attendanceId: String
  ) async throws -> ModifyAttendanceModel? {
    return nil
  }

  public func fetchCount(
    userID: Int
  ) async throws -> AttendanceCountResponseModel {
    return .init(
      attendanceCount: 0,
      presentCount: 0,
      lateCount: 0,
      absentCount: 0,
      exceptionCount: 0,
      tbdCount: 0
    )
  }
}


