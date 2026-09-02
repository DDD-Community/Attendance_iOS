//
//  TargetDependency+Modules.swift
//  Plugins
//
//  레이어 의존성 DSL. 카탈로그가 경로를 들고 있어 여기서는 타깃만 가리킨다.
//  모듈이 Interface 타깃(`Project.makeModule(hasInterface: true)`)을 가지면
//  `.feature(.auth, .interface)` 처럼 어느 타깃에 의존할지 명시할 수 있다.
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
  /// 피처 의존성. 피처끼리는 상대의 Interface 에만 의존하고,
  /// 구현 연결은 조립 레이어(FeatureAssembly/App)에서만 `.implementation` 으로 명시한다.
  static func feature(_ module: FeatureModule, _ target: ModuleTarget = .implementation) -> Self {
    return .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  /// 모든 피처를 묶고 구현을 등록하는 엄브렐러 모듈 (App 진입점).
  static var featureAssembly: Self {
    return .project(target: "FeatureAssembly", path: .relativeToFeature("FeatureAssembly"))
  }

  static func core(_ module: CoreModule, _ target: ModuleTarget = .implementation) -> Self {
    return .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  static func data(_ module: DataModule, _ target: ModuleTarget = .implementation) -> Self {
    return .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  /// Model·Repository를 하나의 Data 진입점으로 제공하는 엄브렐러 모듈.
  static var dataAssembly: Self {
    return .data(.assembly)
  }

  static func service(_ module: ServiceModule, _ target: ModuleTarget = .implementation) -> Self {
    return .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  /// Auth·API 등 Service 구현을 묶어 제공하는 엄브렐러 모듈.
  static var serviceAssembly: Self {
    return .project(target: "ServiceAssembly", path: .relativeToService("ServiceAssembly"))
  }

  static func domain(_ module: DomainModule, _ target: ModuleTarget = .implementation) -> Self {
    return .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }

  /// Entity·DomainInterface·UseCase 를 재수출하는 조립 모듈.
  /// 피처는 도메인 개별 모듈이 아니라 이 문 하나만 본다.
  static var domainAssembly: Self {
    return .domain(.assembly)
  }

  static func ui(_ module: UIModule, _ target: ModuleTarget = .implementation) -> Self {
    return .moduleDependency(name: module.rawValue, path: module.path, target: target)
  }
}
