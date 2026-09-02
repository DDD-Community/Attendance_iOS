//
//  NetworkContainer.swift
//  ServiceAssembly
//
//  Created by DDD on 9/1/26.
//

import CoreAssembly
import DDDAuth
import DDDAuthInterface
import DDDNetworkInterface
import DomainInterface

public enum NetworkContainer {
  private static let assembly = makeAssembly()

  public static var authenticatedClient: any DDDNetworkClient {
    return assembly.authenticatedClient
  }

  public static var authService: any AuthService {
    return assembly.authService
  }

  public static var keychainManager: any KeychainManaging {
    return assembly.keychainManager
  }

  private static func makeAssembly() -> Assembly {
    let plainClient = NetworkAssembly.plainClient()
    let storage = StorageAssembly.secureStorage()
    let keychainManager = KeychainManager(storage: storage)
    let auth = AuthFactory.make(
      refreshClient: plainClient,
      storage: storage
    )

    return Assembly(
      authenticatedClient: auth.authenticatedClient,
      authService: auth,
      keychainManager: keychainManager
    )
  }
}

private extension NetworkContainer {
  struct Assembly {
    let authenticatedClient: any DDDNetworkClient
    let authService: any AuthService
    let keychainManager: any KeychainManaging
  }
}
