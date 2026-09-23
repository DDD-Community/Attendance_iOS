//
//  SelectTeams.swift
//  Entity
//
//  Created by DDD on 12/31/25.
//

public enum SelectTeams: String, CaseIterable, Equatable, CustomStringConvertible {
  case and1 = "AND 1팀"
  case and2 = "AND 2팀"
  case ios1 = "IOS 1팀"
  case ios2 = "IOS 2팀"
  case web1 = "WEB 1팀"
  case web2 = "WEB 2팀"
  case unknown


  public var description: String { rawValue }

  public var managingTeamDesc: String {
    switch self {
    case .web1: return "WEB 1"
    case .web2: return "WEB 2"
    case .and1: return "Android 1"
    case .and2: return "Android 2"
    case .ios1: return "iOS 1"
    case .ios2: return "iOS 2"
    case .unknown: return ""
    }
  }

  public var selectTeamDescription: String {
    switch self {
    case .ios1: return "🍏 iOS 1팀"
    case .ios2: return "🍏 iOS 2팀"
    case .and1: return "🤖 Android 1팀"
    case .and2: return "🤖 Android 2팀"
    case .web1: return "🖥️ WEB 1팀"
    case .web2: return "🖥️ WEB 2팀"
    case .unknown: return ""
    }
  }

  public var attendanceListDescription: String { rawValue }

  public var attandanceCardDescription: String {
    switch self {
    case .web1: return "WEB1팀"
    case .web2: return "WEB2팀"
    case .and1: return "Android1팀"
    case .and2: return "Android2팀"
    case .ios1: return "iOS1팀"
    case .ios2: return "iOS2팀"
    default: return ""
    }
  }

  public static func from(name: String) -> SelectTeams {
    SelectTeams(rawValue: name) ?? .unknown
  }
}
