//
//  AttendanceRepositoryRegistration.swift
//  AttendanceDomain
//
//  Created by DDD on 9/4/26.
//

import AttendanceDomainInterface
import Dependencies

public extension DependencyValues {
  mutating func registerAttendanceRepository() {
    attendanceRepository = resolve { AttendanceRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
