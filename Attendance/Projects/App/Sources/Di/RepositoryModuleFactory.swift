//
//  RepositoryModuleFactory.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

import DiContainer
import Networkings

extension RepositoryModuleFactory {
  public mutating func registerDefaultDefinitions() {
    let registerModuleCopy = registerModule  // self를 직접 캡처하지 않고 복사
    repositoryDefinitions = {
      return [
        registerModuleCopy.makeDependency(AuthRepositoryProtocol.self) { AuthRepository() },
        registerModuleCopy.makeDependency(FireStoreRepositoryProtocol.self) { FireStoreRepository() },
        registerModuleCopy.makeDependency(QrCodeRepositoryProtcol.self) { QrCodeRepository() },
        registerModuleCopy.makeDependency(SignUpRepositoryProtcol.self) { SignUpRepository() }
      ]
    }()
  }
}
