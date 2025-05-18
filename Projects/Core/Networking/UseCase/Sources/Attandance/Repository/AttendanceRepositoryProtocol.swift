//
//  AttendanceRepositoryProtocol.swift
//  UseCase
//
//  Created by Wonji Suh  on 5/10/25.
//

import Model

public protocol AttendanceRepositoryProtocol {
  func attendanceCount(startDate: String) async throws -> AttendanceCountDTOModel?
  func getAttendances(startDate: String) async throws -> AttendanceCheckModel?
  func fillAttendance(team: SelectTeam ,startDate: String) async throws -> AttendanceCheckModel?
}


