//
//  Extension+RepositoryModuleFactory.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

import DiContainer
import Core

extension RepositoryModuleFactory {
  public mutating func registerDefaultDefinitions() {
    let registerModuleCopy = registerModule  // self를 직접 캡처하지 않고 복사
    repositoryDefinitions = {
      return [
        registerModuleCopy.authRepositoryImplModule,
        registerModuleCopy.oAuthRepositoryImplModule,
        registerModuleCopy.qrCodeRepositoryImplModule,
        registerModuleCopy.signUpRepositoryImplModoule,
        registerModuleCopy.profileRepositoryImplModule,
        registerModuleCopy.scheduleRepositoryImplModule,
        registerModuleCopy.attendanceRepositoryImplModule
      ]
    }()
  }
}
