//
//  ScheduleRepositoryRegistration.swift
//  ScheduleDomain
//
//  Created by DDD on 9/4/26.
//

import Dependencies
import ScheduleDomainInterface

public extension DependencyValues {
  mutating func registerScheduleRepository() {
    scheduleRepository = resolve { ScheduleRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
