//
//  FeedbackResults.swift
//  Entity
//
//  Created by Roy on 6/11/26.
//

import Foundation

// MARK: - [운영진] 피드백 결과 집계 (GET /votes/{id}/feedback/results)

public struct FeedbackResults: Equatable, Sendable {
  public let voteId: Int
  public let totalResponses: Int
  public let questions: [FeedbackResultQuestion]

  public init(
    voteId: Int,
    totalResponses: Int,
    questions: [FeedbackResultQuestion]
  ) {
    self.voteId = voteId
    self.totalResponses = totalResponses
    self.questions = questions
  }
}
