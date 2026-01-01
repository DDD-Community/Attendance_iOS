//
//  AttendanceInterface.swift
//  DomainInterface
//
//  Created by Wonji Suh  on 7/23/25.
//

import Foundation
import WeaveDI

/// Attendance 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol AttendanceInterface: Sendable {
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

/// Attendance Repository의 DependencyKey 구조체
public struct AttendanceRepositoryDependency: DependencyKey {
  public static var liveValue: AttendanceInterface {
    UnifiedDI.resolve(AttendanceInterface.self) ?? DefaultAttendanceRepositoryImpl()
  }

  public static var testValue: AttendanceInterface {
    UnifiedDI.resolve(AttendanceInterface.self) ?? DefaultAttendanceRepositoryImpl()
  }

  public static var previewValue: AttendanceInterface = liveValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var attendanceRepository: AttendanceInterface {
    get { self[AttendanceRepositoryDependency.self] }
    set { self[AttendanceRepositoryDependency.self] = newValue }
  }
}
