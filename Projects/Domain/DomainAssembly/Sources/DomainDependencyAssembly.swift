//
//  DomainDependencyAssembly.swift
//  DomainAssembly
//

import Dependencies
import UseCase

public enum DomainDependencyAssembly {
  public static func register(into values: inout DependencyValues) {
    UseCaseDependencyAssembly.register(into: &values)
  }
}
