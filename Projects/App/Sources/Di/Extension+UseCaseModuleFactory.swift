//
// Extension+UseCaseModuleFactory.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

import DiContainer
import Core

extension UseCaseModuleFactory {
  public var useCaseDefinitions: [() -> Module] {
    return [
      registerModule.authUseCaseImplModule,
      registerModule.oAuthUseCaseImplModule,
      registerModule.qrCodeUseCaseImplModule,
      registerModule.signUpUseCaseImplModoule,
      registerModule.profileUseCaseImplModule,
      registerModule.scheduleUseCaseImplModule,
      registerModule.attendanceUseCaseImplModule
    ]
  }
}
