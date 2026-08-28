//
//  TargetDependency+Modules.swift
//  Plugins
//
//  Created by DDD on 2/21/24.
//

import Foundation
import ProjectDescription

// 공통 헬퍼
private extension TargetDependency {
  static func projectTarget(_ name: String, path: ProjectDescription.Path) -> Self {
    .project(target: name, path: path)
  }
}

// Presentation
public extension TargetDependency {
  static func Presentation(implements module: ModulePath.Presentations) -> Self {
    projectTarget(module.rawValue, path: .Presentation(implementation: module))
  }
}

// UI
public extension TargetDependency {
  static func UI(implements module: ModulePath.UIs) -> Self {
    projectTarget(module.rawValue, path: .UI(implementation: module))
  }
}

// Core
public extension TargetDependency {
  static func Core(implements module: ModulePath.Cores) -> Self {
    projectTarget(module.rawValue, path: .Core(implementation: module))
  }
}

// Network
public extension TargetDependency {
  static func Network(implements module: ModulePath.Networks) -> Self {
    projectTarget(module.rawValue, path: .Network(implementation: module))
  }
}

// Domain
public extension TargetDependency {
  static func Domain(implements module: ModulePath.Domains) -> Self {
    projectTarget(module.rawValue, path: .Domain(implementation: module))
  }
}

// Data
public extension TargetDependency {
  static func Data(implements module: ModulePath.Datas) -> Self {
    projectTarget(module.rawValue, path: .Data(implementation: module))
  }
}

