//
//  AttendanceInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//

import Foundation

public protocol AttendanceInterface {
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
