//
//  AppUpdateInterface.swift
//  DomainInterface
//
//  Created by DDD on 3/9/26.
//

import Foundation

import Dependencies

/// App Update 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol AppUpdateInterface: Sendable {
  func checkForUpdate() async throws(AppUpdateError) -> AppUpdateInfo
}

/// AppUpdate Repository의 DependencyKey 구조체
public enum AppUpdateRepositoryDependency: TestDependencyKey {

  public static var testValue: AppUpdateInterface {
    MockAppUpdateRepository()
  }

  public static var previewValue: AppUpdateInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var appUpdateRepository: AppUpdateInterface {
    get { self[AppUpdateRepositoryDependency.self] }
    set { self[AppUpdateRepositoryDependency.self] = newValue }
  }
}
