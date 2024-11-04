//
//  AppDIContainer.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/8/24.
//

import Foundation
import DiContainer
import Networkings

public final class AppDIContainer {
  public static let shared: AppDIContainer = .init()
  
  private let diContainer: DependencyContainer = .live
  
  private init() {
  }
  
  public func registerDependencies() async {
    await registerRepositories()
    await registerUseCases()
  }
  
  // MARK: - Use Cases
  private func registerUseCases() async {
    await registerAuthUseCase()
    await registerFireStoreUseCase()
    await registerQrCodeUseCase()
    await registerOAuthUseCase()
    await registerSignUpUseCase()
  }
  
  private func registerFireStoreUseCase() async {
    await diContainer.register(FireStoreUseCaseProtocol.self) {
      guard let repository = self.diContainer.resolve(FireStoreRepositoryProtocol.self) else {
        assertionFailure("FirestoreRepositoryProtocol must be registered before registering FirestoreUseCaseProtocol")
        return FireStoreUseCase(repository: DefaultFireStoreRepository())
      }
      return FireStoreUseCase(repository: repository)
    }
  }
  
  private func registerQrCodeUseCase() async {
    await diContainer.register(QrCodeUseCaseProtocool.self) {
      guard let repository = self.diContainer.resolve(QrCodeRepositoryProtcool.self) else {
        assertionFailure("FirestoreRepositoryProtocol must be registered before registering FirestoreUseCaseProtocol")
        return QrCodeUseCase(repository: DefaultQrCodeRepository())
      }
      return QrCodeUseCase(repository: repository)
    }
  }
  
  private func registerOAuthUseCase() async {
    await diContainer.register(OAuthUseCaseProtocol.self) {
      guard let repository = self.diContainer.resolve(OAuthRepositoryProtocol.self) else {
        assertionFailure("FirestoreRepositoryProtocol must be registered before registering FirestoreUseCaseProtocol")
        return OAuthUseCase(repository: DefaultOAuthRepository())
      }
      return OAuthUseCase(repository: repository)
    }
  }
  
  private func registerAuthUseCase() async {
    await diContainer.register(AuthUseCaseProtocol.self) {
      guard let repository = self.diContainer.resolve(AuthRepositoryProtocols.self) else {
        assertionFailure("FirestoreRepositoryProtocol must be registered before registering FirestoreUseCaseProtocol")
        return AuthUseCase(repository: DefaultAuthRepository())
      }
      return AuthUseCase(repository: repository)
    }
  }
  
  
  private func registerSignUpUseCase() async {
    await diContainer.register(SignUpUseCaseProtocol.self) {
      guard let repository = self.diContainer.resolve(SignUpRepositoryProtcol.self) else {
        assertionFailure("SignUpRepositoryProtcol must be registered before registering SignUpUseCaseProtocol")
        return SignUpUseCase(repository: DefaultSignUpRepository())
      }
      return SignUpUseCase(repository: repository)
    }
  }
  
  // MARK: - Repositories Registration
  private func registerRepositories() async {
    await registerAuthRepositories()
    await registerFireStoreRepositories()
    await registerQrCodeRepositories()
    await registerOAuthRepositories()
    await registerSignUpRepositories()
  }
  
  private func registerFireStoreRepositories() async {
    await diContainer.register(FireStoreRepositoryProtocol.self) {
      FireStoreRepository()
    }
  }
  
  private func registerQrCodeRepositories() async {
    await diContainer.register(QrCodeRepositoryProtcool.self) {
      QrCodeRepository()
    }
  }
  
  private func registerOAuthRepositories() async {
    await diContainer.register(OAuthRepositoryProtocol.self) {
      OAuthRepository()
    }
  }
  
  private func registerAuthRepositories() async {
    await diContainer.register(AuthRepositoryProtocols.self) {
      AuthRepository()
    }
  }
  
  private func registerSignUpRepositories() async {
    await diContainer.register(SignUpRepositoryProtcol.self) {
      SignUpRepository()
    }
  }
}

