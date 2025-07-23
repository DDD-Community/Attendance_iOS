//
//  AttendanceRepositoryProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/10/25.
//

import Model

public protocol AttendanceRepositoryProtocol {
  func attendanceCount(startDate: String) async throws -> AttendanceCountResponseModel?
  func getAttendances(startDate: String, endDate: String) async throws -> AttendanceListModel?
  func fillAttendance(team: SelectTeam, startDate: String) async throws -> AttendanceListModel?
  func filterScheduleAttendance(
    userId: Int,
    scheduleId: String,
    startDate: String
  ) async throws -> AttendanceListModel?
  func modifyAttendance(attendanceId: String) async throws -> ModifyAttendanceModel?
  func fetchCount(userID: Int) async throws -> AttendanceCountResponseModel
}
