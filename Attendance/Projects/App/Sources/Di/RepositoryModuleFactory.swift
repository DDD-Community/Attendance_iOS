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
    [
      { makeRepositoryModule(AuthRepositoryProtocols.self) { AuthRepository() } },
      { makeRepositoryModule(FireStoreRepositoryProtocol.self) { FireStoreRepository() } },
      { makeRepositoryModule(QrCodeRepositoryProtcool.self) { QrCodeRepository() } },
      { makeRepositoryModule(OAuthRepositoryProtocol.self) { OAuthRepository() } },
      { makeRepositoryModule(SignUpRepositoryProtcol.self) { SignUpRepository() } }
    ]
  }
  
  func makeAllModules() -> [Module] {
    repositoryDefinitions.map { $0() }
  }
  
  private func makeRepositoryModule<T>(
    _ type: T.Type,
    factory: @escaping () -> T
  ) -> Module {
    registerModule.makeModule(type, factory: factory)
  }
}
