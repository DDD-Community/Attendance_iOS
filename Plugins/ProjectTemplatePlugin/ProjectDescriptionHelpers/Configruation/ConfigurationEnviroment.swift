//
//  ConfiguratuonEnviroment.swift
//  DependencyPackagePlugin
//
//  Created by DDD on 7/31/25.
//

import ProjectDescription

/// Stage/Prod 빌드 환경의 단일 출처.
/// Configuration, xcconfig 경로와 debug/release 타입은 모두 여기서 파생한다.
public enum BuildEnvironment: String, CaseIterable, Sendable {
  case stage = "Stage"
  case prod = "Prod"

  public static let development: BuildEnvironment = .stage

  public var name: String {
    return rawValue
  }

  public var configurationName: ConfigurationName {
    return .configuration(rawValue)
  }

  public var isDebug: Bool {
    switch self {
    case .stage:
      return true
    case .prod:
      return false
    }
  }

  public var xcconfigPath: ProjectDescription.Path {
    return .relativeToRoot("Config/\(rawValue).xcconfig")
  }
}
