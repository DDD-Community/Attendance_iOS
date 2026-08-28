//
//  TeamVoteRank.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

public struct TeamVoteRank: Equatable, Identifiable, Sendable {
  public let id: Int
  public let rank: Int
  public let name: String
  public let serviceName: String?
  public let voteCount: Int

  public init(
    rank: Int,
    teamId: Int,
    name: String,
    serviceName: String?,
    voteCount: Int
  ) {
    id = teamId
    self.rank = rank
    self.name = name
    self.serviceName = serviceName
    self.voteCount = voteCount
  }
}
