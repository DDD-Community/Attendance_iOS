//
//  VoteAttendanceMark.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

public enum VoteAttendanceMark: Equatable, Sendable {
  case attended // 출석
  case late // 지각
  case absent // 결석

  public var title: String {
    switch self {
    case .attended: return "출석"
    case .late: return "지각"
    case .absent: return "결석"
    }
  }
}
