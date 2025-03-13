//
//  RepositoryModuleFactory.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

import DiContainer
import Networkings

struct RepositoryModuleFactory {
  private  let registerModule = RegisterModule()
  
  private var repositoryDefinitions: [() -> Module] {
    return [
      registerModule.makeDependency(
        AuthRepositoryProtocol.self) { AuthRepository() },
      registerModule.makeDependency(FireStoreRepositoryProtocol.self) { FireStoreRepository() },
      registerModule.makeDependency(QrCodeRepositoryProtcol.self) { QrCodeRepository() },
      registerModule.makeDependency(SignUpRepositoryProtcol.self) { SignUpRepository() }
    ]
  }
  
  func makeAllModules() -> [Module] {
    repositoryDefinitions.map { $0() }
  }
}
