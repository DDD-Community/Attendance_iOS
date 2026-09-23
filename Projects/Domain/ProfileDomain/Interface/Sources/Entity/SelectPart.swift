//
//  SelectPart.swift
//  Entity
//
//  Created by DDD on 12/30/25.
//

import Foundation

public enum SelectParts: String, CaseIterable, Codable, Equatable {
  case all
  case pm = "PM"
  case designer = "Designer"
  case android = "Android"
  case ios
  case frontend = "FE"
  case backend = "BE"

  public var desc: String {
    switch self {
      case .all:
        return "전체"
      case .pm:
        return "Product Manager"
      case .designer:
        return "Product Designer"
      case .android:
        return "Android"
      case .ios:
        return "iOS"
      case .frontend:
        return "Frontend"
      case .backend:
        return "Backend"
    }
  }

  public var apiKey: String {
    switch self {
      case .all: return "ALL"
      case .backend: return "BACKEND"
      case .frontend: return "FRONTEND"
      case .designer: return "DESIGNER"
      case .pm: return "PM"
      case .android: return "ANDROID"
      case .ios: return "IOS"
    }
  }

  public static func from(apiKey: String) -> SelectParts? {
    switch apiKey.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
      case "ALL": return .all
      case "BACKEND", "BE": return .backend
      case "FRONTEND", "FE": return .frontend
      case "DESIGNER" ,"PD":  return .designer
      case "PM": return .pm
      case "ANDROID", "AND": return .android
      case "IOS": return .ios
      default: return nil
    }
  }
}
