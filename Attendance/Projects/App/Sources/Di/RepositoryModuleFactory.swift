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
      registerModule.makeRepository(AuthRepositoryProtocol.self) { AuthRepository() },
      registerModule.makeRepository(FireStoreRepositoryProtocol.self) { FireStoreRepository() },
      registerModule.makeRepository(QrCodeRepositoryProtcool.self) { QrCodeRepository() },
      registerModule.makeRepository(SignUpRepositoryProtcol.self) { SignUpRepository() }
    ]
  }
  
  func makeAllModules() -> [Module] {
    repositoryDefinitions.map { $0() }
  }
}
