//
//  TargetDependency+Modules.swift
//  Plugins
//
//  레이어 의존성 DSL. 카탈로그가 경로를 들고 있어 여기서는 타깃만 가리킨다.
//  모듈이 Interface 타깃(`Project.makeModule(hasInterface: true)`)을 가지면
//  `.presentation(.auth, .interface)` 처럼 어느 타깃에 의존할지 명시할 수 있다.
//  기본값은 `.implementation` — Interface 를 아직 뚫지 않은 모듈이 대부분이라
//  레이어별로 Interface 가 갖춰지는 대로 기본값을 `.interface` 로 옮긴다.
//

import Foundation
import ProjectDescription

// MARK: - ModuleTarget

/// 모듈 의존 시 어느 타깃을 가리킬지. 레이어 무관 공통 개념.
public enum ModuleTarget {
  case interface
  case implementation
}

extension TargetDependency {
  /// interface → "<name>Interface" 타깃, implementation → "<name>" 타깃.
  static func moduleDependency(name: String, path: Path, target: ModuleTarget) -> TargetDependency {
    switch target {
    case .interface:
      return .project(target: "\(name)Interface", path: path)
    case .implementation:
      return .project(target: name, path: path)
    }
  }
}

// MARK: - Layer DSL

public extension TargetDependency {
  static func presentation(_ module: PresentationModule, _ target: ModuleTarget = .implementation) -> Self {
    .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  static func core(_ module: CoreModule, _ target: ModuleTarget = .implementation) -> Self {
    .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  static func network(_ module: NetworkModule, _ target: ModuleTarget = .implementation) -> Self {
    .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  static func data(_ module: DataModule, _ target: ModuleTarget = .implementation) -> Self {
    .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  static func domain(_ module: DomainModule, _ target: ModuleTarget = .implementation) -> Self {
    .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  static func ui(_ module: UIModule, _ target: ModuleTarget = .implementation) -> Self {
    .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }
}
