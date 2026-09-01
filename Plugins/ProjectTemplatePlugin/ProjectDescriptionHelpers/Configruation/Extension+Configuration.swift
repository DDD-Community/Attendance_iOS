//
//  Extension+Configuration.swift
//  DependencyPackagePlugin
//
//  Created by DDD on 7/31/25.
//

import Foundation
import ProjectDescription

public extension ConfigurationName {
  static let stage = BuildEnvironment.stage.configurationName
  static let prod = BuildEnvironment.prod.configurationName
}

public enum XCConfig {
  /// Joonggonara처럼 환경 enum에서 모든 프로젝트의 Configuration을 파생한다.
  public static let configurations: [Configuration] = BuildEnvironment.allCases.map { environment in
    return environment.isDebug
      ? .debug(name: environment.configurationName, xcconfig: environment.xcconfigPath)
      : .release(name: environment.configurationName, xcconfig: environment.xcconfigPath)
  }
}

public extension ProjectDescription.Path {
  static func path(_ environment: BuildEnvironment) -> Self {
    return environment.xcconfigPath
  }
}
