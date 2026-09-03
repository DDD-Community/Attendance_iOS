//
//  ManagingTeam.swift
//  OnBoardingDomainInterface
//
//  Created by DDD on 11/3/24.
//

import Foundation

public enum SelectTeam: String, CaseIterable, Codable, Equatable, CustomStringConvertible {
  case web1 = "Web_1"
  case web2 = "Web_2"
  case and1 = "Android_1"
  case and2 = "Android_2"
  case ios1 = "iOS_1"
  case ios2 = "iOS_2"
  case notTeam = "NotTeam"
  
  case unknown
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    
    if rawValue.isEmpty {
      self = .unknown
    } else {
      self = SelectTeam(rawValue: rawValue) ?? .unknown
    }
  }
  
  public var description: String {
    switch self {
    case .ios1:
      return "iOS_1"
    case .ios2:
      return "iOS_2"
    case .and1:
      return "Android_1"
    case .and2:
      return "Android_2"
    case .web1:
      return "Web_1"
    case .web2:
      return "Web_2"
    case .notTeam:
      return ""
    case .unknown:
      return ""
    }
  }

  public var managingTeamDesc: String {
    switch self {
    case .ios1:
      return "iOS 1"
    case .ios2:
      return "iOS 2"
    case .and1:
      return "Android 1"
    case .and2:
      return "Android 2"
    case .web1:
      return "Web 1"
    case .web2:
      return "Web 2"
    case .notTeam:
      return ""
    case .unknown:
      return "Unknown Team" // Optional: Description for the unknown case
    }
  }
  
  public var selectTeamDescription: String {
    switch self {
    case .ios1:
      return "🍏 iOS 1팀"
    case .ios2:
      return "🍏 iOS 2팀"
    case .and1:
      return "🤖 Android 1팀"
    case .and2:
      return "🤖 Android 2팀"
    case .web1:
      return "🖥️ Web 1팀"
    case .web2:
      return "🖥️ Web 1팀"
    case .notTeam:
      return ""
    case .unknown:
      return ""
    }
  }
  
  public static var teamList: [SelectTeam] {
    return [.and1, .and2, .ios1, .ios2, .web1, .web2]
  }
  
  // MARK: - 출석 현황 리스트
  public static var attandanceList: [SelectTeam] {
    return [.web1, .web2, .and1, .and2, .ios1, .ios2]
  }
  
  // MARK: - 출석 현황 팀 이름
  public var attendanceListDescription: String {
    switch self {
    case .web1:
      return "Web 1팀"
    case .web2:
      return "Web 2팀"
    case .and1:
      return "Android 1팀"
    case .and2:
      return "Android 2팀"
    case .ios1:
      return "iOS 1팀"
    case .ios2:
      return "iOS 2팀"
    default:
      return ""
    }
  }
  
  public var isDescEqualToAttendanceListDescription: Bool {
    return description == attendanceListDescription
  }
  
  public var attandanceCardDescription: String {
    switch self {
    case .web1:
      return "Web1팀"
    case .web2:
      return "Web2팀"
    case .and1:
      return "Android1팀"
    case .and2:
      return "Android2팀"
    case .ios1:
      return "iOS1팀"
    case .ios2:
      return "iOS2팀"
    default:
      return ""
    }
  }
}
