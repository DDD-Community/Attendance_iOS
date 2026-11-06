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
  case web3 = "WEB 3팀"
  case native1 = "NATIVE 1팀"
  case native2 = "NATIVE 2팀"
  case unknown


  public var description: String { rawValue }

  public var managingTeamDesc: String {
    switch self {
    case .web1: return "WEB 1"
    case .web2: return "WEB 2"
    case .web3: return "WEB 3"
    case .native1: return "Native 1"
    case .native2: return "Native 2"
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
    case .web3: return "🖥️ WEB 3팀"
    case .native1: return "📱 Native 1팀"
    case .native2: return "📱 Native 2팀"
    case .unknown: return ""
    }
  }

  public var attendanceListDescription: String { rawValue }

  public var attandanceCardDescription: String {
    switch self {
    case .web1: return "WEB1팀"
    case .web2: return "WEB2팀"
    case .web3: return "WEB3팀"
    case .native1: return "NATIVE 1팀"
    case .native2: return "NATIVE 2팀"
    case .and1: return "Android1팀"
    case .and2: return "Android2팀"
    case .ios1: return "iOS1팀"
    case .ios2: return "iOS2팀"
    default: return ""
    }
  }

  public static func from(name: String) -> SelectTeams {
    if let team = SelectTeams(rawValue: name) {
      return team
    }

    let normalizedName = name
      .uppercased()
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: "팀", with: "")
    switch normalizedName {
    case "WEB_1", "WEB1": return .web1
    case "WEB_2", "WEB2": return .web2
    case "WEB_3", "WEB3": return .web3
    case "NATIVE_1", "NATIVE1": return .native1
    case "NATIVE_2", "NATIVE2": return .native2
    case "ANDROID_1", "ANDROID1", "AND_1", "AND1": return .and1
    case "ANDROID_2", "ANDROID2", "AND_2", "AND2": return .and2
    case "IOS_1", "IOS1": return .ios1
    case "IOS_2", "IOS2": return .ios2
    default: return .unknown
    }
  }
}
