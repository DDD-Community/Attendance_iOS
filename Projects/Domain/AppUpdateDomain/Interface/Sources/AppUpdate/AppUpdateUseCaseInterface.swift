//
//  AppUpdateUseCaseInterface.swift
//  AppUpdateDomainInterface
//
//  Created by DDD on 9/3/26.
//

import Dependencies

public protocol AppUpdateUseCaseInterface: Sendable {
  func checkForUpdate() async throws(AppUpdateError) -> AppUpdateInfo?
}

public struct MockAppUpdateUseCase: AppUpdateUseCaseInterface {
  public init() {}

  public func checkForUpdate() async throws(AppUpdateError) -> AppUpdateInfo? {
    nil
  }
}

public enum AppUpdateUseCaseDependency: TestDependencyKey {
  public static let testValue: any AppUpdateUseCaseInterface = MockAppUpdateUseCase()
  public static let previewValue: any AppUpdateUseCaseInterface = testValue
}

public extension DependencyValues {
  var appUpdateUseCase: any AppUpdateUseCaseInterface {
    get { self[AppUpdateUseCaseDependency.self] }
    set { self[AppUpdateUseCaseDependency.self] = newValue }
  }
}
