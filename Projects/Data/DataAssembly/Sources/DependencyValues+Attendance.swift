//
//  DependencyValues+Attendance.swift
//  FeatureAssembly
//
//  Created by DDD on 9/2/26.
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
