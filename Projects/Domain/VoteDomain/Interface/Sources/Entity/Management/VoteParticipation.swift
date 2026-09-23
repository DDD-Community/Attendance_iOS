//
//  VoteParticipation.swift
//  Entity
//
//  Created by DDD on 6/11/26.
//

import Foundation

// MARK: - [운영진] 참여 현황

public struct VoteParticipation: Equatable, Sendable {
  public let voteId: Int
  public let status: VoteStatus
  public let totalMembers: Int
  public let respondedMembers: Int
  public let participationRate: Int // %

  public init(
    voteId: Int,
    status: VoteStatus = .before,
    totalMembers: Int,
    respondedMembers: Int,
    participationRate: Int
  ) {
    self.voteId = voteId
    self.status = status
    self.totalMembers = totalMembers
    self.respondedMembers = respondedMembers
    self.participationRate = participationRate
  }
}
