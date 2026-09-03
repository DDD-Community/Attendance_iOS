//
//  DataDependencyAssembly.swift
//  DataAssembly
//

import Dependencies
import Repository
import ServiceAssembly

public enum DataDependencyAssembly {
  public static func register(into values: inout DependencyValues) {
    ServiceDependencyAssembly.register(into: &values)
    values.registerAttendanceRepositories()
    values.registerAuthRepositories()
    values.registerOnBoardingRepositories()
    values.registerProfileRepositories()
    values.registerVoteRepositories()
  }
}
