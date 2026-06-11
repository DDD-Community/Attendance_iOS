//
//  VoteSubmission.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [멤버] 투표 제출 입력 (POST /votes/{id}/responses)

public struct VoteSubmission: Codable, Equatable, Sendable {
  public let teamVote: [TeamVoteAnswer]
  public let feedback: [FeedbackAnswer]

  public init(
    teamVote: [TeamVoteAnswer],
    feedback: [FeedbackAnswer]
  ) {
    self.teamVote = teamVote
    self.feedback = feedback
  }
}
