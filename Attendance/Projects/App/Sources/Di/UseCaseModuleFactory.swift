//
//  UseCaseModuleFactory.swift
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
      registerModule.makeUseCaseWithRepository(
        AuthUseCaseProtocol.self,
        repositoryProtocol: AuthRepositoryProtocol.self,
        repositoryFallback: DefaultAuthRepository()
      ) { repo in
        AuthUseCase(repository: repo)
      },
      registerModule.makeUseCaseWithRepository(
        OAuthUseCaseProtocol.self,
        repositoryProtocol: OAuthRepositoryProtocol.self,
        repositoryFallback: DefaultOAuthRepository()
      ) { repo in
        OAuthUseCase(repository: repo)
      },
      registerModule.makeUseCaseWithRepository(
        FireStoreUseCaseProtocol.self,
        repositoryProtocol: FireStoreRepositoryProtocol.self,
        repositoryFallback: DefaultFireStoreRepository()
      ) { repo in
        FireStoreUseCase(repository: repo)
      },
      registerModule.makeUseCaseWithRepository(
        QrCodeUseCaseProtocol.self,
        repositoryProtocol: QrCodeRepositoryProtcol.self,
        repositoryFallback: DefaultQrCodeRepository()
      ) { repo in
        QrCodeUseCase(repository: repo)
      },
      registerModule.makeUseCaseWithRepository(
        SignUpUseCaseProtocol.self,
        repositoryProtocol: SignUpRepositoryProtcol.self,
        repositoryFallback: DefaultSignUpRepository()
      ) { repo in
        SignUpUseCase(repository: repo)
      }
    ]
  }
}
