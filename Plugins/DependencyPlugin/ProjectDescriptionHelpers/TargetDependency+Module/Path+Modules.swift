//
//  Path+Modules.swift
//  Plugins
//
//  레이어 루트 경로. 카탈로그가 rawValue 만 넘겨 재사용한다.
//

import Foundation
import ProjectDescription

public extension ProjectDescription.Path {
  static func relativeToPresentation(_ name: String) -> Self {
    .relativeToRoot("Projects/Presentation/\(name)")
  }

  static func relativeToCore(_ name: String) -> Self {
    .relativeToRoot("Projects/Core/\(name)")
  }

  static func relativeToNetwork(_ name: String) -> Self {
    .relativeToRoot("Projects/Network/\(name)")
  }

  static func relativeToData(_ name: String) -> Self {
    .relativeToRoot("Projects/Data/\(name)")
  }

  static func relativeToDomain(_ name: String) -> Self {
    .relativeToRoot("Projects/Domain/\(name)")
  }

  static func relativeToUI(_ name: String) -> Self {
    .relativeToRoot("Projects/UI/\(name)")
  }
}
