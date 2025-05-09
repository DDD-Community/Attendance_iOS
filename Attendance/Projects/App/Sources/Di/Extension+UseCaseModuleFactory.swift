//
// Extension+UseCaseModuleFactory.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

import DiContainer
import Networkings

extension UseCaseModuleFactory {
  public var useCaseDefinitions: [() -> Module] {
    return [
      registerModule.authUseCaseModule,
      registerModule.oAuthUseCaseModule,
      registerModule.fireStoreUseCaseModule,
      registerModule.qrCodeUseCaseModule,
      registerModule.signUpUseCaseModoule,
      registerModule.profileUseCaseModule
    ]
  }
}
