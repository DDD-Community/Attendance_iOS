//
//  UseCaseModuleFactory.swift
//  DDDAttendance
//
//  Created by Wonji Suh  on 12/2/24.
//

import Foundation

import DiContainer
import Networkings

struct UseCaseModuleFactory {
  let registerModule = RegisterModule()
  
  private var useCaseDefinitions: [() -> Module] {
    return [
      registerModule.makeUseCase(AuthUseCaseProtocol.self) {
          AuthUseCase(
            repository: registerModule
              .resolveOrDefault(
                AuthRepositoryProtocol.self,
                default: DefaultAuthRepository())
        )
      },
      registerModule.makeUseCase(FireStoreUseCaseProtocol.self) {
        FireStoreUseCase(
            repository: registerModule
              .resolveOrDefault(
                FireStoreRepositoryProtocol.self,
                default: DefaultFireStoreRepository())
        )
      },
      registerModule.makeUseCase(QrCodeUseCaseProtocool.self) {
        QrCodeUseCase(
            repository: registerModule
              .resolveOrDefault(
                QrCodeRepositoryProtcool.self,
                default: DefaultQrCodeRepository())
        )
      },
      registerModule.makeUseCase(OAuthUseCaseProtocol.self) {
        OAuthUseCase(
            repository: registerModule
              .resolveOrDefault(
                OAuthRepositoryProtocol.self,
                default: DefaultOAuthRepository())
        )
      },
      registerModule.makeUseCase(SignUpUseCaseProtocol.self) {
        SignUpUseCase(
            repository: registerModule
              .resolveOrDefault(
                SignUpRepositoryProtcol.self,
                default: DefaultSignUpRepository())
        )
      },
      ]
  }
  
  func makeAllModules() -> [Module] {
    useCaseDefinitions.map { $0() }
  }
}
