//
//  AppUpdateUseCaseImpl.swift
//  UseCase
//
//  Created by DDD on 3/9/26.
//

import DomainInterface
import Entity
import ComposableArchitecture

public protocol AppUpdateUseCaseInterface: Sendable {
    func checkForUpdate() async throws -> AppUpdateInfo?
}

public struct AppUpdateUseCaseImpl: AppUpdateUseCaseInterface {
  @Dependency(\.appUpdateRepository) var repository

  public init() {}

  public func checkForUpdate() async throws -> AppUpdateInfo? {
    let updateInfo = try await repository.checkForUpdate()

    // 업데이트가 필요한 경우만 반환
    if updateInfo.isUpdateAvailable {
      return updateInfo
    }

    return nil
  }
}

extension AppUpdateUseCaseImpl: DependencyKey {
  public static var liveValue: AppUpdateUseCaseInterface = AppUpdateUseCaseImpl()
  public static var testValue: AppUpdateUseCaseInterface = AppUpdateUseCaseImpl()
  public static var previewValue: AppUpdateUseCaseInterface = liveValue
}

public extension DependencyValues {
  var appUpdateUseCase: AppUpdateUseCaseInterface {
    get { self[AppUpdateUseCaseImpl.self] }
    set { self[AppUpdateUseCaseImpl.self] = newValue }
  }
}
