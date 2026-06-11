//
//  NonParticipant.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

public struct NonParticipant: Equatable, Identifiable, Sendable {
  public let id: Int // memberId
  public let name: String
  public let teamName: String
  public let attendance: VoteAttendanceMark?

  public init(
    id: Int,
    name: String,
    teamName: String,
    attendance: VoteAttendanceMark? = nil
  ) {
    self.id = id
    self.name = name
    self.teamName = teamName
    self.attendance = attendance
  }
}

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
