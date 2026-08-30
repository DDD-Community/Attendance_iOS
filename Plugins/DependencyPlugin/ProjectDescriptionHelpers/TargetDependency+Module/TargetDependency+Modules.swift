//
//  TargetDependency+Modules.swift
//  Plugins
//
//  레이어 의존성 DSL. 카탈로그가 경로를 들고 있어 여기서는 타깃만 가리킨다.
//  DDD 모듈은 Interface 타깃을 따로 두지 않으므로 interface/implementation 구분이 없다.
//  (경계가 필요한 곳은 DomainInterface 처럼 별도 모듈로 존재한다)
//

import Foundation
import ProjectDescription

public extension TargetDependency {
  static func presentation(_ module: PresentationModule) -> Self {
    .project(target: module.rawValue, path: module.path)
  }

  static func core(_ module: CoreModule) -> Self {
    .project(target: module.rawValue, path: module.path)
  }

  static func network(_ module: NetworkModule) -> Self {
    .project(target: module.rawValue, path: module.path)
  }

  static func data(_ module: DataModule) -> Self {
    .project(target: module.rawValue, path: module.path)
  }

  static func domain(_ module: DomainModule) -> Self {
    .project(target: module.rawValue, path: module.path)
  }

  static func ui(_ module: UIModule) -> Self {
    .project(target: module.rawValue, path: module.path)
  }
}
