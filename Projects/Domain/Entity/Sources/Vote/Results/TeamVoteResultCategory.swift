//
//  TeamVoteResultCategory.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

public struct TeamVoteResultCategory: Equatable, Identifiable, Sendable {
  public let id: String
  public let title: String
  public let order: Int
  public let teams: [TeamVoteRank]
  public let reasons: [String]

  public init(
    id: String,
    title: String,
    order: Int,
    teams: [TeamVoteRank],
    reasons: [String]
  ) {
    self.id = id
    self.title = title
    self.order = order
    self.teams = teams
    self.reasons = reasons
  }
}
