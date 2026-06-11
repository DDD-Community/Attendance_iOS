//
//  TeamVoteAnswer.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

public struct TeamVoteAnswer: Codable, Equatable, Sendable {
  public let categoryId: String
  public let teamIds: [Int]
  public let reason: String?
  
  public init(
    categoryId: String,
    teamIds: [Int],
    reason: String?
  ) {
    self.categoryId = categoryId
    self.teamIds = teamIds
    self.reason = reason
  }
}
