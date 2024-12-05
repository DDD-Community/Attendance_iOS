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
    [
      {
        self.makeModule(AuthUseCaseProtocol.self) {
          AuthUseCases(
            repository: self.resolveOrDefault(
              AuthRepositoryProtocol.self,
              default: DefaultAuthRepository())
          )}
      },
      
      {
        self.makeModule(FireStoreUseCaseProtocol.self) {
          FireStoreUseCase(
            repository: self.resolveOrDefault(
              FireStoreRepositoryProtocol.self,
              default: DefaultFireStoreRepository())
          )}
      },
      
      {
        self.makeModule(QrCodeUseCaseProtocool.self) {
          QrCodeUseCase(
            repository: self.resolveOrDefault(
              QrCodeRepositoryProtcool.self,
              default: DefaultQrCodeRepository())
          )}
      },
      
      {
        self.makeModule(OAuthUseCaseProtocol.self) {
          OAuthUseCase(
            repository: self.resolveOrDefault(
              OAuthRepositoryProtocol.self,
              default: DefaultOAuthRepository())
          )}
      },
      {
        self.makeModule(SignUpUseCaseProtocol.self) {
          SignUpUseCase(
            repository: self.resolveOrDefault(
              SignUpRepositoryProtcol.self,
              default: DefaultSignUpRepository())
          )}
      },
    ]
  }
  
  func makeAllModules() -> [Module] {
    useCaseDefinitions.map { $0() }
  }
  
  private func makeModule<T>(
    _ type: T.Type,
    factory: @escaping () -> T
  ) -> Module {
    registerModule.makeModule(type, factory: factory)
  }
  
  private func resolveOrDefault<T>(
    _ type: T.Type,
    default defaultFactory: @autoclosure @escaping () -> T
  ) -> T {
    DependencyContainer.live.resolveOrDefault(type, default: defaultFactory())
  }
}
