//
//  AttendanceInterface.swift
//  DomainInterface
//
//  Created by DDD on 7/23/25.
//

import Foundation
import Entity
import WeaveDI

/// Attendance 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol AttendanceInterface: Sendable {
  func adminAttendanceCount(scheduleId: Int) async throws -> AttendanceCount
  func fetchAttendanceTeams() async throws -> [SelectTeamEntity]
  func sessionAttendance(scheduleId: Int, teamId: Int) async throws -> [Attendance]
  func fetchStatus() async throws -> [AttendanceStatus]
  func editAttendance(input: EditAttendanceInput) async throws -> EditAttendance
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
