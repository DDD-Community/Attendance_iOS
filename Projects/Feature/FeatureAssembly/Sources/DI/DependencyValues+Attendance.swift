//
//  DependencyValues+Attendance.swift
//  FeatureAssembly
//
//  출석·일정·QR 구현 등록.
//  인터페이스(TestDependencyKey)에 실제 구현(liveValue)을 붙이는 조립 지점.
//

import Dependencies
import DomainInterface

import Repository

extension AttendanceRepositoryDependency: DependencyKey {
  public static var liveValue: AttendanceInterface { AttendanceRepositoryImpl() }
}

extension ScheduleRepositoryDependency: DependencyKey {
  public static var liveValue: ScheduleInterface { ScheduleRepositoryImpl() }
}

extension QRCodeRepositoryDependency: DependencyKey {
  public static var liveValue: QRCodeInterface { QRCodeRepositoryImpl() }
}
