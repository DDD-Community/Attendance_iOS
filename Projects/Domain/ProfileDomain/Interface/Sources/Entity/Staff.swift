//
//  Staff.swift
//  Entity
//
//  Created by DDD on 12/30/25.
//

import Foundation

public enum Staff: String, CaseIterable, Equatable, Sendable {
  case member
  case manager

  public var description: String {
    switch self {
      case .member:
        return "MEMBER"
      case .manager:
        return "MANAGER"
    }
  }

  public static func from(apiKey: String) -> Staff? {
    Staff(rawValue: apiKey.lowercased())
  }
}
