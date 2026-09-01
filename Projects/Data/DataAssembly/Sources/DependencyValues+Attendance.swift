//
//  DependencyValues+Attendance.swift
//  FeatureAssembly
//
//  출석·일정·QR 구현 등록.
//  인터페이스(TestDependencyKey)에 실제 구현(liveValue)을 붙이는 조립 지점.
//

import Dependencies
import DomainInterface

extension AttendanceRepositoryDependency: DependencyKey {
  public static var liveValue: AttendanceInterface {
    return RepositoryFactory.attendance
  }
}

extension ScheduleRepositoryDependency: DependencyKey {
  public static var liveValue: ScheduleInterface {
    return RepositoryFactory.schedule
  }
}

extension QRCodeRepositoryDependency: DependencyKey {
  public static var liveValue: QRCodeInterface {
    return RepositoryFactory.qrCode
  }
}
