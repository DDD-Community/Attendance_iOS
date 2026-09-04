//
//  ConfigurationEnviroment.swift
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

  /// Stage 시뮬레이터 빌드는 현재 Mac 아키텍처만 생성한다.
  /// Xcode 26에서 arm64/x86_64 Swift 프레임워크를 동시에 만들 때 발생하는
  /// explicit module 스캔과 Swift 호환 헤더 충돌을 피하고 로컬·CI 빌드 시간을 줄인다.
  public var buildSettings: SettingsDictionary {
    switch self {
    case .stage:
      return ["ONLY_ACTIVE_ARCH": "YES"]
    case .prod:
      return ["ONLY_ACTIVE_ARCH": "NO"]
    }
  }

  public var xcconfigPath: ProjectDescription.Path {
    return .relativeToRoot("Config/\(rawValue).xcconfig")
  }
}
