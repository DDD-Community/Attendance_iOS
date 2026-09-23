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

public enum NetworkContainer {
  private static let assembly = makeAssembly()

  public static var authenticatedClient: any DDDNetworkClient {
    return assembly.authenticatedClient
  }

  public static var authService: any AuthService {
    return assembly.authService
  }

  private static func makeAssembly() -> Assembly {
    let plainClient = NetworkAssembly.plainClient()
    let storage = StorageAssembly.secureStorage()
    let auth = AuthFactory.make(
      refreshClient: plainClient,
      storage: storage
    )

    return Assembly(
      authenticatedClient: auth.authenticatedClient,
      authService: auth
    )
  }
}

private extension NetworkContainer {
  struct Assembly {
    let authenticatedClient: any DDDNetworkClient
    let authService: any AuthService
  }
}
