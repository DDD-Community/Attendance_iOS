//
//  ProfileRepositoryRegistration.swift
//  ProfileDomain
//
//  Created by DDD on 9/4/26.
//

import Dependencies
import ProfileDomainInterface

public extension DependencyValues {
  mutating func registerProfileRepository() {
    profileRepository = resolve { ProfileRepositoryImpl() }
  }

  private func resolve<Value>(_ makeValue: () -> Value) -> Value {
    withDependencies { $0 = self } operation: { makeValue() }
  }
}
