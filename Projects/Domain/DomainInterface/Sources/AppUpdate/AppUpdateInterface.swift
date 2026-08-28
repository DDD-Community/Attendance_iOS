//
//  AppUpdateInterface.swift
//  DomainInterface
//
//  Created by DDD on 3/9/26.
//

import Foundation
import WeaveDI
import Entity

/// App Update 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol AppUpdateInterface: Sendable {
  func checkForUpdate() async throws -> AppUpdateInfo
}

/// AppUpdate Repository의 DependencyKey 구조체
public struct AppUpdateRepositoryDependency: DependencyKey {
  public static var liveValue: AppUpdateInterface {
    UnifiedDI.resolve(AppUpdateInterface.self) ?? DefaultAppUpdateRepositoryImpl()
  }

  public static var testValue: AppUpdateInterface {
    UnifiedDI.resolve(AppUpdateInterface.self) ?? DefaultAppUpdateRepositoryImpl()
  }

  public static var previewValue: AppUpdateInterface = liveValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var appUpdateRepository: AppUpdateInterface {
    get { self[AppUpdateRepositoryDependency.self] }
    set { self[AppUpdateRepositoryDependency.self] = newValue }
  }
}
