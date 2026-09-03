//
//  UseCaseDependencyAssembly.swift
//  UseCase
//

import Dependencies

public enum UseCaseDependencyAssembly {
  public static func register(into values: inout DependencyValues) {
    values.registerAttendanceUseCases()
    values.registerAuthUseCases()
    values.registerProfileUseCases()
    values.registerOnBoardingUseCases()
    values.registerVoteUseCases()
  }
}
