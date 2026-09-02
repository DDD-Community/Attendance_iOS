//
//  DependencyValues+Core.swift
//  ServiceAssembly
//
//  Created by DDD on 9/2/26.
//

import Dependencies
import DomainInterface

extension KeychainManagerDependency: DependencyKey {
  public static var liveValue: KeychainManaging {
    return NetworkContainer.keychainManager
  }
}
