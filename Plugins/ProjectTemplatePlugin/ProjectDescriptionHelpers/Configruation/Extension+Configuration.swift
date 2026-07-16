//
//  Extension+Configuration.swift
//  DependencyPackagePlugin
//
//  Created by Wonji Suh  on 7/31/25.
//

import Foundation
import ProjectDescription

extension ConfigurationName {
  static let dev = ConfigurationName.configuration(ConfigurationEnvironment.dev.name)
  static let stage = ConfigurationName.configuration(ConfigurationEnvironment.stage.name)
  static let prod = ConfigurationName.configuration(ConfigurationEnvironment.prod.name)
}

public extension Array where Element == Configuration {
  static let `default`: [Configuration] = [
    .debug(name: .dev, xcconfig: .path(.dev)),
    .debug(name: .stage, xcconfig: .path(.stage)),
    .debug(name: .prod, xcconfig: .path(.prod)),
    .release(name: .release, xcconfig: .path(.release))
  ]

  /// 워크스페이스 전 프로젝트가 공유해야 하는 표준 config 목록.
  /// App(appMainSetting)의 config 이름/타입과 정확히 일치해야 Stage/Prod config 로
  /// 빌드할 때 의존 모듈의 패키지 의존성이 해당 config 에서 정상 해석된다.
  /// (xcconfig 는 App 전용이므로 모듈에는 붙이지 않는다.)
  static let moduleDefault: [Configuration] = [
    .debug(name: .debug),
    .debug(name: .stage),
    .release(name: .prod),
    .release(name: .release)
  ]
}

public extension ProjectDescription.Path {
  static func path(_ configuration: ConfigurationName) -> Self {
    return .relativeToRoot("Config/\(configuration.rawValue).xcconfig")
  }
}
