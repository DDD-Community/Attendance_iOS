//
//  ServiceDependencyAssembly.swift
//  ServiceAssembly
//

import DDDAuthInterface
import DDDNetworkInterface
import Dependencies

public enum ServiceDependencyAssembly {
  public static func register(into values: inout DependencyValues) {
    values.registerLiveServices()
  }
}

public extension DependencyValues {
  mutating func registerLiveServices() {
    networkClient = NetworkContainer.authenticatedClient
    authService = NetworkContainer.authService
  }
}
