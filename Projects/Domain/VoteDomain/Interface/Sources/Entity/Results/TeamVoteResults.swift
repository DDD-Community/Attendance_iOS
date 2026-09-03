//
//  TeamVoteResults.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 팀 투표 결과 집계 (GET /votes/{id}/team-vote/results)

public struct TeamVoteResults: Equatable, Sendable {
  public let voteId: Int
  public let title: String
  public let status: VoteStatus
  public let totalResponses: Int
  public let categories: [TeamVoteResultCategory]

  public init(
    voteId: Int,
    title: String,
    status: VoteStatus,
    totalResponses: Int,
    categories: [TeamVoteResultCategory]
  ) {
    self.voteId = voteId
    self.title = title
    self.status = status
    self.totalResponses = totalResponses
    self.categories = categories
  }
}
