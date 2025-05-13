//
//  Extension+RepositoryModuleFactory.swift
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
        registerModuleCopy.authRepositoryModule,
        registerModuleCopy.oAuthRepositoryModule,
        registerModuleCopy.fireStoreRepositoryModule,
        registerModuleCopy.qrCodeRepositoryModule,
        registerModuleCopy.signUpRepositoryModoule,
        registerModuleCopy.profileRepositoryModule,
        registerModuleCopy.scheduleRepositoryModule,
        registerModuleCopy.attendanceRepositoryModule
      ]
    }()
  }
}
