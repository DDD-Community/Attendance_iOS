//
//  AttendanceUseCaseProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/10/25.
//

import Model

public protocol AttendanceUseCaseProtocol {
  func attendanceCount(startDate: String) async throws -> AttendanceCountResponseModel?
  func getAttendances(startDate: String) async throws -> AttendanceCheckModel?
  func fillAttendance(team: SelectTeam ,startDate: String) async throws -> AttendanceCheckModel?
  func filterScheduleAttendance(
    userId: Int,
    scheduleId: String
  ) async throws -> AttendanceCheckModel?
  func modifyAttendance(attendanceId: String) async throws -> ModifyAttendanceModel?
  func fetchCount(userID: Int) async throws -> AttendanceCountResponseModel
}
