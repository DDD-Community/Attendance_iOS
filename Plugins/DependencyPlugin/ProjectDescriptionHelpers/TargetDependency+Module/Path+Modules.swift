//
//  Path+Modules.swift
//  Plugins
//
//  레이어 루트 경로. 카탈로그가 rawValue 만 넘겨 재사용한다.
//

import Foundation
import ProjectDescription

public extension ProjectDescription.Path {
  static func relativeToFeature(_ name: String) -> Self {
    return .relativeToRoot("Projects/Feature/\(name)")
  }

  static func relativeToCore(_ name: String) -> Self {
    return .relativeToRoot("Projects/Core/\(name)")
  }

  static func relativeToData(_ name: String) -> Self {
    return .relativeToRoot("Projects/Data/\(name)")
  }

  static func relativeToService(_ name: String) -> Self {
    return .relativeToRoot("Projects/Service/\(name)")
  }

  static func relativeToDomain(_ name: String) -> Self {
    return .relativeToRoot("Projects/Domain/\(name)")
  }

  static func relativeToUI(_ name: String) -> Self {
    return .relativeToRoot("Projects/UI/\(name)")
  }
}
