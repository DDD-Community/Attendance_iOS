//
//  NonParticipant.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 미참여 멤버 명단

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
